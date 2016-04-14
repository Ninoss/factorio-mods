function pretty(value,htchar,lfchar,indent)
  local str
  if htchar == nil then htchar = "\t" end
  if lfchar == nil then lfchar = "\n" end
  if indent == nil then indent = 0 end
  if type(value)=="table" then
    str = {}
    for key,v in pairs(value) do 
      table.insert(str, string.format(
        "%s%s%s:%s", 
        lfchar, 
        string.rep(htchar,indent+1), 
        string.format("%q", key):gsub("\\\n", "\\n"), 
        pretty(value[key],htchar,lfchar,indent+1)))
    end
    return string.format("{%s%s%s}",table.concat(str,","),lfchar,string.rep(htchar,indent))
  elseif type(value)=="nil" then
    return "nil"
  elseif type(value)=="boolean" then
    if value then return "true" else return "false" end
  elseif type(value)=="string" then
    return string.format("%q", value):gsub("\\\n", "\\n")
  else
    return tostring(value)
  end
end
--print(serpent.block(data.raw, {name="data.raw"}))
--print(pretty(data.raw,"  "))
function print(st)
	for id, p in pairs(game.players) do
		p.print(st)
	end
end
remote.add_interface("p", {
	-- remote.call("p", "prety", obj)
	pretty = function(value)
		print("Testing 123")
		print("Testing 123")
		print("Testing 123")
		print(pretty(value))
	end
})
