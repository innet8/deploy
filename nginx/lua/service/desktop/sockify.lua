local code = string.gsub(ngx.var.uri, "/", "")
local token = ngx.var.arg_token

function os.split(str, split_char)
  local sub_str_tab = {}
  while (true) do
    local pos = string.find(str, split_char)
    if (not pos) then
      sub_str_tab[#sub_str_tab + 1] = str
      break
    end
    local sub_str = string.sub(str, 1, pos - 1)
    sub_str_tab[#sub_str_tab + 1] = sub_str
    str = string.sub(str, pos + 1, #str)
  end

  return sub_str_tab
end

function os.capture(cmd, raw)
  local f = assert(io.popen(cmd, "r"))
  local s = assert(f:read("*a"))
  f:close()
  if raw then
    return s
  end
  s = string.gsub(s, "^%s+", "")
  s = string.gsub(s, "%s+$", "")
  s = string.gsub(s, "[\n\r]+", " ")
  return s
end

local ipcd = ngx.re.sub(ngx.var.uri, "^/desktop/sockify/([0-9]+)/([0-9]+)$", "$1.$2", "o")
local check =
  os.capture(
  "wget --header='token:" .. token .. "' -q -O - 'http://172.111.0.2:5200/api/desktop/nginx/check?ipcd=" .. ipcd .. "'"
)

local strs = os.split(check, ":")
if strs[1] == "ok" then
  return true
end

ngx.header.content_type = "text/text"
ngx.say(check)
ngx.exit(ngx.HTTP_OK)
