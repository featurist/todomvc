plastiq = require 'plastiq'
h = plastiq.html
bind = plastiq.bind

render (state) =
  h 'section#plastiq-todomvc' (
    h 'section#todoapp' (
      header (state)
      main (state)
      footer (state)
    )
    info (state)
  )

header (state) =
  h 'header#header' (
    h 'h1' 'todos'
    h 'input#new-todo' {
      placeholder = "What needs to be done?"
      autofocus = true
      binding = bind(state, 'title')
      onkeyup (e) = if (isEnterKey (e)) @{ state.createTodo() }
    }
  )

main (state) =
  if (state.todos.length > 0)
    h 'section#main' (
      h 'input#toggle-all' {
        type = 'checkbox'
        checked = state.allCompleted()
        onclick () = state.toggleAll()
      }
      h 'label' { htmlFor = 'toggle-all' } 'Mark all as complete'
      h 'ul#todo-list' (
        state.todos.map @(todo)
          todoItem (todo, state)
      )
    )

todoItem (todo, state) =
  h 'li' { className = todoClass(todo) } (
    h 'div.view' (
      h 'input.toggle' { type = 'checkbox', binding = bind(todo, 'completed') }
      h 'label' { ondblclick () = (todo.editing = true) } (todo.title)
      h 'button.destroy' { onclick () = state.destroyTodo (todo) }
    )
    h 'input.edit' {
      binding = bind(todo, 'title')
      onkeyup (e) =
        if (isEnterKey(e))
          todo.editing = false
    }
  )

todoClass(todo) =
  classes = []
  if (todo.completed) @{ classes.push 'completed' }
  if (todo.editing) @{ classes.push 'editing' }
  classes.join(' ')

footer (state) =
  h 'footer#footer' (
    h 'span#todo-count' (
      h 'strong' (state.todos.length)
      if (state.todos.length == 1) @{ ' item' } else @{ ' items' }
      ' left'
    )
    h 'button#clear-completed' {
      disabled = (state.countCompleted() == 0)
      onclick () = state.clearCompleted()
    } "Clear completed (#(state.countCompleted()))"
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

  createTodo () =
    if (self.title != '')
      todo = { title = self.title, completed = false }
      self.title = ''
      self.todos.push(todo)

  destroyTodo (todo) =
    self.todos.splice(self.todos.indexOf(todo), 1)

  toggleAll () =
    completed = @not self.allCompleted()
    self.todos.forEach @(todo)
      todo.completed = completed

  countCompleted () =
    [ t <- self.todos, t.completed, t ].length

  allCompleted () =
    self.countCompleted () == self.todos.length

  clearCompleted() =
    [ t <- self.todos, t.completed, self.destroyTodo(t) ]
}

plastiq.attach (document.body, render, model)
