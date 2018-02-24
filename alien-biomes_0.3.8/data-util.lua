local util = {}
util.str_gsub = string.gsub

function util.replace(str, what, with)
    what = util.str_gsub(what, "[%(%)%.%+%-%*%?%[%]%^%$%%]", "%%%1") -- escape pattern
    with = util.str_gsub(with, "[%%]", "%%%%") -- escape replacement
    return util.str_gsub(str, what, with)
end

function util.replace_filenames_recursive(subject, what, with)
  for _, sub in pairs(subject) do
    if (type(sub) == "table") then
      util.replace_filenames_recursive(sub, what, with)
    elseif _ == "filename" then
      subject.filename = util.replace(subject.filename, what, with)
    end
  end
end

return util
