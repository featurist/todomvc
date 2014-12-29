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
  if (model.todos.length > 0)
    h 'section#main' (
      h 'input#toggle-all' {
        type       = 'checkbox'
        checked    = model.allCompleted()
        onclick () = model.toggleAll()
      }
      h "label" { htmlFor = 'toggle-all' } 'Mark all as complete'
      h 'ul#todo-list' [t <- model.filteredTodos(), todoItem (t, model)]
    )

todoItem (todo, model) =
  h 'li' { className = { completed = todo.completed, editing = todo.editing } } (
    h 'div.view' (
      h 'input.toggle'   { type = 'checkbox', binding = bind(todo, 'completed') }
      h 'label'          { ondblclick () = (todo.editing = true) } (todo.title)
      h 'button.destroy' { onclick () = model.destroyTodo (todo) }
    )
    h 'input.edit' {
      binding     = bind(todo, 'title')
      onkeyup (e) = (todo.editing = @not isEnterKey(e))
    }
  )

footer (model) =
  h 'footer#footer' (
    h 'span#todo-count' (
      h 'strong' (model.todos.length)
      if (model.todos.length == 1) @{ ' item left' } else @{ ' items left' }
    )
    h 'ul#filters' (
      filter (model, 'All')
      filter (model, 'Active')
      filter (model, 'Completed')
    )
    if (model.countCompleted () > 0)
      h 'button#clear-completed' { onclick () = model.clearCompleted () } (
        "Clear completed (#(model.countCompleted()))"
      )
  )

filter (model, name) =
  h 'li' (
    h 'a' {
      href = "##(name)"
      className = { selected = model.filter == name }
      onclick (e) =
        e.preventDefault ()
        model.filter = name
    } (name)
  )

info () =
  h 'footer#info' (
    h 'p' 'Double-click to edit a todo'
    h 'p' (
      'Created with '
      h 'a' { href = 'https://github.com/featurist/plastiq' } 'Plastiq'
    )
    h 'p' (
      'Part of '
      h 'a' { href = 'http://todomvc.com' } 'TodoMVC'
    )
  )

isEnterKey (e) = e.keyCode == 13

model = {
  title = ''
  todos = []
  filter = 'All'

  filters = {
    All ()       = self.todos
    Active ()    = [ t <- self.todos, @not t.completed, t ]
    Completed () = [ t <- self.todos, t.completed, t ]
  }

  filteredTodos () =
    self.filters.(self.filter).call(self)

  createTodo () =
    if (self.title != '')
      self.todos.push { title = self.title, completed = false }
      self.title = ''

  destroyTodo (todo) =
    self.todos.splice (self.todos.indexOf(todo), 1)

  toggleAll () =
    completed = @not self.allCompleted ()
    [ t <- self.todos, t.completed = completed ]

  countCompleted () =
    [ t <- self.todos, t.completed, t ].length

  allCompleted () =
    self.countCompleted () == self.todos.length

  clearCompleted () =
    [ t <- [].concat (self.todos), t.completed, self.destroyTodo (t) ]
}

plastiq.attach (document.body, render, model)
