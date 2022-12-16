defmodule VkBotTest do
  use ExUnit.Case
  doctest VkBot

  test "greets the world" do
    assert VkBot.hello() == :world
  end
end
