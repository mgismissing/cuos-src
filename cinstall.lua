local required_version = nil

print("Checking for CIManage...")
if fs.exists("/cuprum/cimanage.lua") then
    print("A valid installation of CIManage has been found. Proceeding...")
else
    print("CIManage could not be found on your system, starting automatic installation...")
    print("Fetching data...")
    local cuprum_src_url = "http://raw.githubusercontent.com/mgismissing/cuprum-src/refs/heads/main/"
    local response = http.get(cuprum_src_url .. "cimanage.lua")
    if response then
        print("Saving data...")
        local content = response.readAll()
        local file = fs.open("/cuprum/cimanage.lua", "w")
        file.write(content)
        file.close()
        print("Done.")
    else
        print("Fetch error caused by the following errors:")
        term.setTextColor(colors.red)
        print("Source website doesn't have CIManage.")
        print("ERR_FETCH_NO_CIMANAGE")
    end
end
term.setTextColor(colors.white)
print()
os.run({}, "/cuprum/cimanage.lua", required_version)