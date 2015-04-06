def module Extract.Meta.Options do

  def allow_undefined(opts) do
    Keyword.get(opts, :optional, false) or Keyword.get(opts, :undefined, false)
  end


  def allow_missing(opts) do
    Keyword.get(opts, :optional, false) or Keyword.get(opts, :missing, false)
  end

end