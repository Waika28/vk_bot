commands do
  command "test", CommandModule
  # триггер на /test

  text "test", CommandModule
  # триггер на сообщение test

  regex "[]().+", CommandModule
  # триггер на сообщение если регекс
end
