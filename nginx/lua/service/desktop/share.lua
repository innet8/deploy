local code = string.gsub(ngx.var.uri,"/","")
local token = ngx.var.arg_token

function os.capture(cmd, raw)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  if raw then return s end
  s = string.gsub(s, '^%s+', '')
  s = string.gsub(s, '%s+$', '')
  s = string.gsub(s, '[\n\r]+', ' ')
  return s
end

local ipcd = ngx.re.sub(ngx.var.uri, "^/desktop/share/([0-9]+)/([0-9]+)/(.*?)$", "$1.$2", "o")
local sharekey = ngx.re.sub(ngx.var.uri, "^/desktop/share/([0-9]+)/([0-9]+)/(.*?)$", "$3", "o")

local check = os.capture("wget --header='token:"..token.."' -q -O - 'http://172.111.0.2:5200/api/desktop/nginx/check?share_key=" .. sharekey .. "&ipcd=" .. ipcd .. "'")
if check == "ok"  then
    return true
end

ngx.header.content_type = 'text/text'
ngx.say(check)
ngx.exit(ngx.HTTP_OK)

