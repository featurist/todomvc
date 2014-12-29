plastiq = require 'plastiq'
h = plastiq.html
bind = plastiq.bind

render (model) =
  h 'section#plastiq-todomvc' (
    h 'section#todoapp' (
      header (model)
      main   (model)
      footer (model)
    )
    info ()
  )

header (model) =
  h 'header#header' (
    h 'h1' 'todos'
    h 'input#new-todo' {
      placeholder = 'What needs to be done?'
      autofocus   = true
      binding     = bind(model, 'title')
      onkeyup (e) = if (isEnterKey (e)) @{ model.createTodo() }
    }
  )

main (model) =
  todos = model.filteredTodos()
  if (todos.length > 0)
    h 'section#main' (
      h 'input#toggle-all' {
        type       = 'checkbox'
        checked    = model.allCompleted()
        onclick () = model.toggleAll()
      }
      h "label" { for = 'toggle-all' } 'Mark all as complete'
      h 'ul#todo-list' [t <- todos, todoItem (t, model)]
    )

todoItem (todo, model) =
  editing = (model.editing == todo)
  h 'li' { class = { completed = todo.completed, editing = editing } } (
    h 'div.view' (
      h 'input.toggle' { type = 'checkbox', binding = bind(todo, 'completed') }
      h 'label' { ondblclick () = model.editing = todo } (todo.title)
      h 'button.destroy' { onclick () = model.destroyTodo (todo) }
    )
    h 'input.edit' {
      binding     = bind(todo, 'title')
      onblur ()   = model.editing = nil
      onkeyup (e) =
        if (isEnterKey(e) @or isEscapeKey(e))
          model.editing = nil
    }
  )

footer (model) =
  active = model.countActive ()
  completed = model.countCompleted ()
  h 'footer#footer' (
    h 'span#todo-count' (
      h 'strong' (active)
      if (active == 1) @{ ' item left' } else @{ ' items left' }
    )
    h 'ul#filters' (
      filter (model, 'All')
      filter (model, 'Active')
      filter (model, 'Completed')
    )
    if (completed > 0)
      h 'button#clear-completed' { onclick () = model.clearCompleted () } (
        "Clear completed (#( completed ))"
      )
  )

filter (model, name) =
  h 'li' (
    h 'a' {
      href = "##(name)"
      class = { selected = (model.filter == name) }
      onclick (e) =
        e.preventDefault ()
        model.filter = name
    } (name)
  )

info () =
  h 'footer#info' (
    h 'p' 'Double-click to edit a todo'
    h 'p' (
      'Created by '
      h 'a' { href = 'https://github.com/joshski' } 'Josh Chisholm'
    )
    h 'p' (
      'Part of '
      h 'a' { href = 'http://todomvc.com' } 'TodoMVC'
    )
  )

isEnterKey (e) = e.keyCode == 13
isEscapeKey (e) = e.keyCode == 27

model = {
  title = ''
  todos = []
  filter = 'All'
  editing = nil

  filters = {
    All (todos)       = todos
    Active (todos)    = [ t <- todos, @not t.completed, t ]
    Completed (todos) = [ t <- todos, t.completed, t ]
  }

  filteredTodos () =
    self.todosInState (self.filter)

  todosInState (state) =
    self.filters.(state).call (self, self.todos)

  createTodo () =
    if (self.title != '')
      self.todos.push { title = self.title, completed = false }
      self.title = ''

  destroyTodo (todo) =
    self.todos.splice (self.todos.indexOf(todo), 1)

  toggleAll () =
    completed = @not self.allCompleted ()
    [ t <- self.todos, t.completed = completed ]

  countActive () =
    self.todosInState ('Active').length

  countCompleted () =
    self.todosInState ('Completed').length

  allCompleted () =
    self.countCompleted () == self.todos.length

  clearCompleted () =
    [ t <- self.todosInState ('Completed'), self.destroyTodo (t) ]
}

plastiq.attach (document.body, render, model)
