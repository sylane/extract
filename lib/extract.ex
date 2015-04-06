defmodule Extract do

  require Extract.Meta


  defmacro __using__(_kv) do
    quote do
      import Extract, only: :macros
      require Extract.Types
      @before_compile Extract
      defmacro __using__(_kv) do
        quote do
          require unquote(__MODULE__)
        end
      end
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      # Extract.headline "!", "before #{__MODULE__}"
    end
  end

  defmacro extract(type, kv) do
    type = Macro.to_string(type)
    code = Macro.escape(Keyword.fetch!(kv, :do))
    headline "!", "#{inspect type}"
    headline "-", "AST"
    IO.puts inspect code
    headline "-", "Code"
    IO.puts Macro.to_string(code)
    headline "-"
    newline
    quote do: :ok
  end

  defmacro condence([{:"->", _, [[from], to]}], kv) do
    code = Macro.escape(Keyword.fetch!(kv, :do))
    headline ">", "#{inspect from} -> #{inspect to}"
    headline "-", "AST"
    IO.puts inspect code
    headline "-", "Code"
    IO.puts Macro.to_string(code)
    headline "-"
    newline
    quote do: :ok
  end

  defmacro condence({:"<>", _, [from, to]}, kv) do
    code = Macro.escape(Keyword.fetch!(kv, :do))
    headline "=", "#{inspect from} <> #{inspect to}"
    headline "-", "AST"
    IO.puts inspect code
    headline "-", "Code"
    IO.puts Macro.to_string(code)
    headline "-"
    newline
    quote do: :ok
  end

  @total_size  60
  @prefix_size 10

  def headline(char, header) do
    str = to_string(header)
    prefix = String.duplicate(char, @prefix_size)
    postfix_size = max(0, @total_size - 2 - @prefix_size - String.length(str))
    postfix = String.duplicate(char, postfix_size)
    IO.puts "#{prefix} #{str} #{postfix}"
  end

  def headline(char) do
    IO.puts String.duplicate(char, @total_size)
  end

  def newline do
    IO.puts ""
  end

end
