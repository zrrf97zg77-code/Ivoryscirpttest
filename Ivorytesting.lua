local player = game:GetService("Players").LocalPlayer
local pg = player:FindFirstChild("PlayerGui")

print("=== SKILL BUTTON SCAN ===")
local count = 0
for _, obj in pairs(pg:GetDescendants()) do
    if obj:IsA("ImageButton") or obj:IsA("TextButton") then
        local name = obj.Name
        if name == "Z" or name == "X" or name == "C" or name == "V" or name == "F" then
            count = count + 1
            print(string.format(
                "FOUND: name=%s class=%s visible=%s pos=%s size=%s parent=%s",
                name, obj.ClassName, tostring(obj.Visible),
                tostring(obj.AbsolutePosition), tostring(obj.AbsoluteSize),
                tostring(obj.Parent and obj.Parent.Name)
            ))
        end
    end
end
print("=== TOTAL FOUND: " .. count .. " ===")
