local required_version = nil

print("Checking for CUOSIM...")
if fs.exists("/cuos/cuosim.lua") then
    print("A valid installation of CUOSIM has been found. Proceeding...")
    os.run({}, "/cuos/cuosim.lua", required_version)
else
    print("CUOSIM could not be found on your system, starting automatic installation...")
    print("Fetching data...")
    local cuos_src_url = "http://raw.githubusercontent.com/mgismissing/cuos-src/refs/heads/main/"
    local response = http.get(cuos_src_url .. "cuosim.lua")
    if response then
        print("Saving data...")
        local content = response.readAll()
        local file = fs.open("/cuos/cuosim.lua", "w")
        file.write(content)
        file.close()
        print("Done.")
    else
        print("Fetch error caused by the following errors:")
        term.setTextColor(colors.red)
        print("Source website doesn't have CUOSIM.")
        print("ERR_FETCH_NO_CUOSIM")
    end
end
term.setTextColor(colors.white)
