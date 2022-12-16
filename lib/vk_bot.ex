defmodule VkBot do
  defmacro __using__(_opts) do
    quote do
      use VkBot.Bot
    end
  end
end
