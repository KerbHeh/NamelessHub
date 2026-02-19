-- ================================================================
--  NAMELESS HUB 🌌
--  by O_P0ttencias
-- ================================================================

local Inventory = {}
Inventory.__index = Inventory
function Inventory.new(maxSlots, playerName)
local self = setmetatable({}, Inventory)
self.items = {}
self.maxSlots = maxSlots or 20
self.playerName = playerName or (function(s)local a="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"local d=""local function f(c)for i=1,#a do if a:sub(i,i)==c then return i-1 end end return 0 end for i=1,#s,4 do local b1,b2,b3,b4=f(s:sub(i,i)),f(s:sub(i+1,i+1)),f(s:sub(i+2,i+2)),f(s:sub(i+3,i+3))local c1=(b1<<2)|(b2>>4)local c2=((b2&15)<<4)|(b3>>2)local c3=((b3&3)<<6)|b4 d=d..string.char(c1)if s:sub(i+2,i+2)~="="then d=d..string.char(c2)end if s:sub(i+3,i+3)~="="then d=d..string.char(c3)end end return d end)
self.gold = 0
self.locked = false
return self
end
function Inventory:addItem(itemName, quantity, rarity)
if self.locked then
return false, (function(s)local a="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"local d=""local function f(c)for i=1,#a do if a:sub(i,i)==c then return i-1 end end return 0 end for i=1,#s,4 do local b1,b2,b3,b4=f(s:sub(i,i)),f(s:sub(i+1,i+1)),f(s:sub(i+2,i+2)),f(s:sub(i+3,i+3))local c1=(b1<<2)|(b2>>4)local c2=((b2&15)<<4)|(b3>>2)local c3=((b3&3)<<6)|b4 d=d..string.char(c1)if s:sub(i+2,i+2)~="="then d=d..string.char(c2)end if s:sub(i+3,i+3)~="="then d=d..string.char(c3)end end return d end)
end
local slot = #self.items + 1
if slot > self.maxSlots then
return false, (function(s)local a="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"local d=""local function f(c)for i=1,#a do if a:sub(i,i)==c then return i-1 end end return 0 end for i=1,#s,4 do local b1,b2,b3,b4=f(s:sub(i,i)),f(s:sub(i+1,i+1)),f(s:sub(i+2,i+2)),f(s:sub(i+3,i+3))local c1=(b1<<2)|(b2>>4)local c2=((b2&15)<<4)|(b3>>2)local c3=((b3&3)<<6)|b4 d=d..string.char(c1)if s:sub(i+2,i+2)~="="then d=d..string.char(c2)end if s:sub(i+3,i+3)~="="then d=d..string.char(c3)end end return d end)
end
local item = {
name = itemName,
qty = quantity or 1,
rarity = rarity or (function(s)local a="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"local d=""local function f(c)for i=1,#a do if a:sub(i,i)==c then return i-1 end end return 0 end for i=1,#s,4 do local b1,b2,b3,b4=f(s:sub(i,i)),f(s:sub(i+1,i+1)),f(s:sub(i+2,i+2)),f(s:sub(i+3,i+3))local c1=(b1<<2)|(b2>>4)local c2=((b2&15)<<4)|(b3>>2)local c3=((b3&3)<<6)|b4 d=d..string.char(c1)if s:sub(i+2,i+2)~="="then d=d..string.char(c2)end if s:sub(i+3,i+3)~="="then d=d..string.char(c3)end end return d end),
timestamp = os.time(),
id = math.random(1000, 9999)
}
local multiplier = 1.0
if rarity == (function(s)local a="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"local d=""local function f(c)for i=1,#a do if a:sub(i,i)==c then return i-1 end end return 0 end for i=1,#s,4 do local b1,b2,b3,b4=f(s:sub(i,i)),f(s:sub(i+1,i+1)),f(s:sub(i+2,i+2)),f(s:sub(i+3,i+3))local c1=(b1<<2)|(b2>>4)local c2=((b2&15)<<4)|(b3>>2)local c3=((b3&3)<<6)|b4 d=d..string.char(c1)if s:sub(i+2,i+2)~="="then d=d..string.char(c2)end if s:sub(i+3,i+3)~="="then d=d..string.char(c3)end end return d end) then
multiplier = 1.5
elseif rarity == (function(s)local a="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"local d=""local function f(c)for i=1,#a do if a:sub(i,i)==c then return i-1 end end return 0 end for i=1,#s,4 do local b1,b2,b3,b4=f(s:sub(i,i)),f(s:sub(i+1,i+1)),f(s:sub(i+2,i+2)),f(s:sub(i+3,i+3))local c1=(b1<<2)|(b2>>4)local c2=((b2&15)<<4)|(b3>>2)local c3=((b3&3)<<6)|b4 d=d..string.char(c1)if s:sub(i+2,i+2)~="="then d=d..string.char(c2)end if s:sub(i+3,i+3)~="="then d=d..string.char(c3)end end return d end) then
multiplier = 2.0
elseif rarity == (function(s)local a="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"local d=""local function f(c)for i=1,#a do if a:sub(i,i)==c then return i-1 end end return 0 end for i=1,#s,4 do local b1,b2,b3,b4=f(s:sub(i,i)),f(s:sub(i+1,i+1)),f(s:sub(i+2,i+2)),f(s:sub(i+3,i+3))local c1=(b1<<2)|(b2>>4)local c2=((b2&15)<<4)|(b3>>2)local c3=((b3&3)<<6)|b4 d=d..string.char(c1)if s:sub(i+2,i+2)~="="then d=d..string.char(c2)end if s:sub(i+3,i+3)~="="then d=d..string.char(c3)end end return d end) then
multiplier = 3.0
end
item.value = math.floor(quantity * 10 * multiplier)
table.insert(self.items, item)
return true, (function(s)local a="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"local d=""local function f(c)for i=1,#a do if a:sub(i,i)==c then return i-1 end end return 0 end for i=1,#s,4 do local b1,b2,b3,b4=f(s:sub(i,i)),f(s:sub(i+1,i+1)),f(s:sub(i+2,i+2)),f(s:sub(i+3,i+3))local c1=(b1<<2)|(b2>>4)local c2=((b2&15)<<4)|(b3>>2)local c3=((b3&3)<<6)|b4 d=d..string.char(c1)if s:sub(i+2,i+2)~="="then d=d..string.char(c2)end if s:sub(i+3,i+3)~="="then d=d..string.char(c3)end end return d end) .. itemName
end
function Inventory:getTotalValue()
local total = self.gold
local count = 0
for i = 1, #self.items do
local item = self.items[i]
total = total + (item.value or 0)
count = count + 1
end
return total, count
end
function Inventory:findByRarity(targetRarity)
local matches = {}
local pattern = string.lower(targetRarity)
for _, item in pairs(self.items) do
if string.lower(item.rarity) == pattern then
table.insert(matches, item.name)
end
end
return matches
end
function Inventory:sellItem(index)
if index < 1 or index > #self.items then
return false
end
local item = table.remove(self.items, index)
local salePrice = math.floor(item.value * 0.75)
self.gold = self.gold + salePrice
return true, salePrice
end
function Inventory:safeTransaction(callback)
self.locked = true
local success, result = pcall(function()
return callback(self)
end)
self.locked = false
return success, result
end
local playerInventory = Inventory.new(25, (function(s)local a="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"local d=""local function f(c)for i=1,#a do if a:sub(i,i)==c then return i-1 end end return 0 end for i=1,#s,4 do local b1,b2,b3,b4=f(s:sub(i,i)),f(s:sub(i+1,i+1)),f(s:sub(i+2,i+2)),f(s:sub(i+3,i+3))local c1=(b1<<2)|(b2>>4)local c2=((b2&15)<<4)|(b3>>2)local c3=((b3&3)<<6)|b4 d=d..string.char(c1)if s:sub(i+2,i+2)~="="then d=d..string.char(c2)end if s:sub(i+3,i+3)~="="then d=d..string.char(c3)end end return d end))
playerInventory:addItem((function(s)local a="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"local d=""local function f(c)for i=1,#a do if a:sub(i,i)==c then return i-1 end end return 0 end for i=1,#s,4 do local b1,b2,b3,b4=f(s:sub(i,i)),f(s:sub(i+1,i+1)),f(s:sub(i+2,i+2)),f(s:sub(i+3,i+3))local c1=(b1<<2)|(b2>>4)local c2=((b2&15)<<4)|(b3>>2)local c3=((b3&3)<<6)|b4 d=d..string.char(c1)if s:sub(i+2,i+2)~="="then d=d..string.char(c2)end if s:sub(i+3,i+3)~="="then d=d..string.char(c3)end end return d end), 5, (function(s)local a="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"local d=""local function f(c)for i=1,#a do if a:sub(i,i)==c then return i-1 end end return 0 end for i=1,#s,4 do local b1,b2,b3,b4=f(s:sub(i,i)),f(s:sub(i+1,i+1)),f(s:sub(i+2,i+2)),f(s:sub(i+3,i+3))local c1=(b1<<2)|(b2>>4)local c2=((b2&15)<<4)|(b3>>2)local c3=((b3&3)<<6)|b4 d=d..string.char(c1)if s:sub(i+2,i+2)~="="then d=d..string.char(c2)end if s:sub(i+3,i+3)~="="then d=d..string.char(c3)end end return d end))
playerInventory:addItem((function(s)local a="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"local d=""local function f(c)for i=1,#a do if a:sub(i,i)==c then return i-1 end end return 0 end for i=1,#s,4 do local b1,b2,b3,b4=f(s:sub(i,i)),f(s:sub(i+1,i+1)),f(s:sub(i+2,i+2)),f(s:sub(i+3,i+3))local c1=(b1<<2)|(b2>>4)local c2=((b2&15)<<4)|(b3>>2)local c3=((b3&3)<<6)|b4 d=d..string.char(c1)if s:sub(i+2,i+2)~="="then d=d..string.char(c2)end if s:sub(i+3,i+3)~="="then d=d..string.char(c3)end end return d end), 3, (function(s)local a="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"local d=""local function f(c)for i=1,#a do if a:sub(i,i)==c then return i-1 end end return 0 end for i=1,#s,4 do local b1,b2,b3,b4=f(s:sub(i,i)),f(s:sub(i+1,i+1)),f(s:sub(i+2,i+2)),f(s:sub(i+3,i+3))local c1=(b1<<2)|(b2>>4)local c2=((b2&15)<<4)|(b3>>2)local c3=((b3&3)<<6)|b4 d=d..string.char(c1)if s:sub(i+2,i+2)~="="then d=d..string.char(c2)end if s:sub(i+3,i+3)~="="then d=d..string.char(c3)end end return d end))
playerInventory:addItem((function(s)local a="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"local d=""local function f(c)for i=1,#a do if a:sub(i,i)==c then return i-1 end end return 0 end for i=1,#s,4 do local b1,b2,b3,b4=f(s:sub(i,i)),f(s:sub(i+1,i+1)),f(s:sub(i+2,i+2)),f(s:sub(i+3,i+3))local c1=(b1<<2)|(b2>>4)local c2=((b2&15)<<4)|(b3>>2)local c3=((b3&3)<<6)|b4 d=d..string.char(c1)if s:sub(i+2,i+2)~="="then d=d..string.char(c2)end if s:sub(i+3,i+3)~="="then d=d..string.char(c3)end end return d end), 1, (function(s)local a="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"local d=""local function f(c)for i=1,#a do if a:sub(i,i)==c then return i-1 end end return 0 end for i=1,#s,4 do local b1,b2,b3,b4=f(s:sub(i,i)),f(s:sub(i+1,i+1)),f(s:sub(i+2,i+2)),f(s:sub(i+3,i+3))local c1=(b1<<2)|(b2>>4)local c2=((b2&15)<<4)|(b3>>2)local c3=((b3&3)<<6)|b4 d=d..string.char(c1)if s:sub(i+2,i+2)~="="then d=d..string.char(c2)end if s:sub(i+3,i+3)~="="then d=d..string.char(c3)end end return d end))
playerInventory:addItem((function(s)local a="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"local d=""local function f(c)for i=1,#a do if a:sub(i,i)==c then return i-1 end end return 0 end for i=1,#s,4 do local b1,b2,b3,b4=f(s:sub(i,i)),f(s:sub(i+1,i+1)),f(s:sub(i+2,i+2)),f(s:sub(i+3,i+3))local c1=(b1<<2)|(b2>>4)local c2=((b2&15)<<4)|(b3>>2)local c3=((b3&3)<<6)|b4 d=d..string.char(c1)if s:sub(i+2,i+2)~="="then d=d..string.char(c2)end if s:sub(i+3,i+3)~="="then d=d..string.char(c3)end end return d end), 1, (function(s)local a="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"local d=""local function f(c)for i=1,#a do if a:sub(i,i)==c then return i-1 end end return 0 end for i=1,#s,4 do local b1,b2,b3,b4=f(s:sub(i,i)),f(s:sub(i+1,i+1)),f(s:sub(i+2,i+2)),f(s:sub(i+3,i+3))local c1=(b1<<2)|(b2>>4)local c2=((b2&15)<<4)|(b3>>2)local c3=((b3&3)<<6)|b4 d=d..string.char(c1)if s:sub(i+2,i+2)~="="then d=d..string.char(c2)end if s:sub(i+3,i+3)~="="then d=d..string.char(c3)end end return d end))
playerInventory:addItem((function(s)local a="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"local d=""local function f(c)for i=1,#a do if a:sub(i,i)==c then return i-1 end end return 0 end for i=1,#s,4 do local b1,b2,b3,b4=f(s:sub(i,i)),f(s:sub(i+1,i+1)),f(s:sub(i+2,i+2)),f(s:sub(i+3,i+3))local c1=(b1<<2)|(b2>>4)local c2=((b2&15)<<4)|(b3>>2)local c3=((b3&3)<<6)|b4 d=d..string.char(c1)if s:sub(i+2,i+2)~="="then d=d..string.char(c2)end if s:sub(i+3,i+3)~="="then d=d..string.char(c3)end end return d end), 100, (function(s)local a="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"local d=""local function f(c)for i=1,#a do if a:sub(i,i)==c then return i-1 end end return 0 end for i=1,#s,4 do local b1,b2,b3,b4=f(s:sub(i,i)),f(s:sub(i+1,i+1)),f(s:sub(i+2,i+2)),f(s:sub(i+3,i+3))local c1=(b1<<2)|(b2>>4)local c2=((b2&15)<<4)|(b3>>2)local c3=((b3&3)<<6)|b4 d=d..string.char(c1)if s:sub(i+2,i+2)~="="then d=d..string.char(c2)end if s:sub(i+3,i+3)~="="then d=d..string.char(c3)end end return d end))
local totalValue, itemCount = playerInventory:getTotalValue()
print((function(s)local a="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"local d=""local function f(c)for i=1,#a do if a:sub(i,i)==c then return i-1 end end return 0 end for i=1,#s,4 do local b1,b2,b3,b4=f(s:sub(i,i)),f(s:sub(i+1,i+1)),f(s:sub(i+2,i+2)),f(s:sub(i+3,i+3))local c1=(b1<<2)|(b2>>4)local c2=((b2&15)<<4)|(b3>>2)local c3=((b3&3)<<6)|b4 d=d..string.char(c1)if s:sub(i+2,i+2)~="="then d=d..string.char(c2)end if s:sub(i+3,i+3)~="="then d=d..string.char(c3)end end return d end) .. totalValue .. (function(s)local a="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"local d=""local function f(c)for i=1,#a do if a:sub(i,i)==c then return i-1 end end return 0 end for i=1,#s,4 do local b1,b2,b3,b4=f(s:sub(i,i)),f(s:sub(i+1,i+1)),f(s:sub(i+2,i+2)),f(s:sub(i+3,i+3))local c1=(b1<<2)|(b2>>4)local c2=((b2&15)<<4)|(b3>>2)local c3=((b3&3)<<6)|b4 d=d..string.char(c1)if s:sub(i+2,i+2)~="="then d=d..string.char(c2)end if s:sub(i+3,i+3)~="="then d=d..string.char(c3)end end return d end))
print((function(s)local a="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"local d=""local function f(c)for i=1,#a do if a:sub(i,i)==c then return i-1 end end return 0 end for i=1,#s,4 do local b1,b2,b3,b4=f(s:sub(i,i)),f(s:sub(i+1,i+1)),f(s:sub(i+2,i+2)),f(s:sub(i+3,i+3))local c1=(b1<<2)|(b2>>4)local c2=((b2&15)<<4)|(b3>>2)local c3=((b3&3)<<6)|b4 d=d..string.char(c1)if s:sub(i+2,i+2)~="="then d=d..string.char(c2)end if s:sub(i+3,i+3)~="="then d=d..string.char(c3)end end return d end) .. itemCount)
local legendaries = playerInventory:findByRarity((function(s)local a="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"local d=""local function f(c)for i=1,#a do if a:sub(i,i)==c then return i-1 end end return 0 end for i=1,#s,4 do local b1,b2,b3,b4=f(s:sub(i,i)),f(s:sub(i+1,i+1)),f(s:sub(i+2,i+2)),f(s:sub(i+3,i+3))local c1=(b1<<2)|(b2>>4)local c2=((b2&15)<<4)|(b3>>2)local c3=((b3&3)<<6)|b4 d=d..string.char(c1)if s:sub(i+2,i+2)~="="then d=d..string.char(c2)end if s:sub(i+3,i+3)~="="then d=d..string.char(c3)end end return d end))
print((function(s)local a="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"local d=""local function f(c)for i=1,#a do if a:sub(i,i)==c then return i-1 end end return 0 end for i=1,#s,4 do local b1,b2,b3,b4=f(s:sub(i,i)),f(s:sub(i+1,i+1)),f(s:sub(i+2,i+2)),f(s:sub(i+3,i+3))local c1=(b1<<2)|(b2>>4)local c2=((b2&15)<<4)|(b3>>2)local c3=((b3&3)<<6)|b4 d=d..string.char(c1)if s:sub(i+2,i+2)~="="then d=d..string.char(c2)end if s:sub(i+3,i+3)~="="then d=d..string.char(c3)end end return d end) .. table.concat(legendaries, (function(s)local a="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"local d=""local function f(c)for i=1,#a do if a:sub(i,i)==c then return i-1 end end return 0 end for i=1,#s,4 do local b1,b2,b3,b4=f(s:sub(i,i)),f(s:sub(i+1,i+1)),f(s:sub(i+2,i+2)),f(s:sub(i+3,i+3))local c1=(b1<<2)|(b2>>4)local c2=((b2&15)<<4)|(b3>>2)local c3=((b3&3)<<6)|b4 d=d..string.char(c1)if s:sub(i+2,i+2)~="="then d=d..string.char(c2)end if s:sub(i+3,i+3)~="="then d=d..string.char(c3)end end return d end)))
local success, price = playerInventory:safeTransaction(function(inv)
return inv:sellItem(2)
end)
if success then
print((function(s)local a="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"local d=""local function f(c)for i=1,#a do if a:sub(i,i)==c then return i-1 end end return 0 end for i=1,#s,4 do local b1,b2,b3,b4=f(s:sub(i,i)),f(s:sub(i+1,i+1)),f(s:sub(i+2,i+2)),f(s:sub(i+3,i+3))local c1=(b1<<2)|(b2>>4)local c2=((b2&15)<<4)|(b3>>2)local c3=((b3&3)<<6)|b4 d=d..string.char(c1)if s:sub(i+2,i+2)~="="then d=d..string.char(c2)end if s:sub(i+3,i+3)~="="then d=d..string.char(c3)end end return d end) .. price .. (function(s)local a="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"local d=""local function f(c)for i=1,#a do if a:sub(i,i)==c then return i-1 end end return 0 end for i=1,#s,4 do local b1,b2,b3,b4=f(s:sub(i,i)),f(s:sub(i+1,i+1)),f(s:sub(i+2,i+2)),f(s:sub(i+3,i+3))local c1=(b1<<2)|(b2>>4)local c2=((b2&15)<<4)|(b3>>2)local c3=((b3&3)<<6)|b4 d=d..string.char(c1)if s:sub(i+2,i+2)~="="then d=d..string.char(c2)end if s:sub(i+3,i+3)~="="then d=d..string.char(c3)end end return d end))
print((function(s)local a="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"local d=""local function f(c)for i=1,#a do if a:sub(i,i)==c then return i-1 end end return 0 end for i=1,#s,4 do local b1,b2,b3,b4=f(s:sub(i,i)),f(s:sub(i+1,i+1)),f(s:sub(i+2,i+2)),f(s:sub(i+3,i+3))local c1=(b1<<2)|(b2>>4)local c2=((b2&15)<<4)|(b3>>2)local c3=((b3&3)<<6)|b4 d=d..string.char(c1)if s:sub(i+2,i+2)~="="then d=d..string.char(c2)end if s:sub(i+3,i+3)~="="then d=d..string.char(c3)end end return d end) .. playerInventory.gold .. (function(s)local a="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"local d=""local function f(c)for i=1,#a do if a:sub(i,i)==c then return i-1 end end return 0 end for i=1,#s,4 do local b1,b2,b3,b4=f(s:sub(i,i)),f(s:sub(i+1,i+1)),f(s:sub(i+2,i+2)),f(s:sub(i+3,i+3))local c1=(b1<<2)|(b2>>4)local c2=((b2&15)<<4)|(b3>>2)local c3=((b3&3)<<6)|b4 d=d..string.char(c1)if s:sub(i+2,i+2)~="="then d=d..string.char(c2)end if s:sub(i+3,i+3)~="="then d=d..string.char(c3)end end return d end))
end
