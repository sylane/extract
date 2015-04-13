defmodule Proto.Request do

  # use Extract
  # use Proto.Types
  # use Proto.Request.Push

  defstruct [:id, :command, data: nil]

  # @commands [:ping, :register, :login, :push]
  # @lookup   %{ping: Request.Ping,
  #             register: Request.Register,
  #             login: Request.Login,
  #             push: Request.Push}

  # extract :struct do
  #   "request" :: struct Request do
  #     "identifier" ::  :id      |> string
  #     "command"    ::  :command |> atom allowed: @commands
  #     "data"       ::  :data    |> delegate @lookup
  #   end
  # end

  # extract :term do
  #   "request" :: map stash: [rid: :id, command: :comand] do
  #     "type"       ::  :type    |> string "request"
  #     "identifier" ::  :rid     |> string
  #     "command"    ::  :command |> atom allowed: @commands
  #     "data"       ::  :data    |> delegate @lookup
  #   end
  # end

  # extract :poison do
  #   "request" :: map stash: [rid: :id, command: :comand] do
  #     "type"       ::  "type"    |> string "request"
  #     "identifier" ::  "id"      |> string
  #     "command"    ::  "command" |> string
  #     "data"       ::  "data"    |> delegate @lookup
  #   end
  # end
end
