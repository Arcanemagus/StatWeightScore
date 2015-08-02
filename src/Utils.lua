local SWS_ADDON_NAME, StatWeightScore = ...;
local Utils = {};

local L = StatWeightScore.L;

StatWeightScore.Utils = Utils;

Utils.SortedKeys = function(t, sortFunction)
    local keys, len = {}, 0;
    for k,_ in pairs(t) do
        len = len + 1;
        keys[len] = k;
    end

    table.sort(keys, sortFunction);
    return keys;
end;

Utils.OrderKeysBy = function(array, property)
    return Utils.SortedKeys(array, function(key1, key2)
        return array[key1][property] < array[key2][property];
    end)
end;

Utils.ToNumber = function(s)
    if(type(s) == "number") then
        return s
    end

    s = s:gsub(L["ThousandSeparator"], ""):gsub(L["DecimalSeparator"], ".");

    return tonumber(s);
end;

local DecimalSeparator = gsub(L["DecimalSeparator"], "%%", "");
local ThousandSeparator = gsub(L["ThousandSeparator"], "%%", "");

Utils.Round = function(val, decimal)
    if (decimal) then
        return math.floor( (val * 10^decimal) + 0.5) / (10^decimal)
    else
        return math.floor(val+0.5)
    end
end

Utils.FormatNumber = function (amount, decimal, prefix, neg_prefix)
    local str_amount,  formatted, famount, remain

    decimal = decimal or 0  -- default 0 decimal places
    neg_prefix = neg_prefix or "-" -- default negative sign

    famount = math.abs(Utils.Round(amount,decimal))
    famount = math.floor(famount)

    remain = Utils.Round(math.abs(amount) - famount, decimal)

    -- comma to separate the thousandslocal formatted = tostring(num);
    local k;
    local formatted = tostring(famount);

    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1"..ThousandSeparator.."%2");
        if (k == 0) then
            break;
        end
    end

    -- attach the decimal portion
    if (decimal > 0) then
        remain = string.sub(tostring(remain),3)
        formatted = formatted ..DecimalSeparator.. remain ..
                string.rep("0", decimal - string.len(remain))
    end

    -- attach prefix string e.g '$'
    formatted = (prefix or "") .. formatted

    -- if value is negative then format accordingly
    if (amount<0) then
        if (neg_prefix=="()") then
            formatted = "("..formatted ..")"
        else
            formatted = neg_prefix .. formatted
        end
    end

    return formatted
end

Utils.Pack = function(...)
    if(... == nil) then
        return nil
    end

    return { n = select("#", ...), ... };
end;

Utils.Print = function(text)
    if(text == nil) then
        text = "-nil-";
    end

    if(type(text) == "table") then
        print(SWS_ADDON_NAME.." (table):")
        for i,v in pairs(text) do
            print(i.." : "..tostring(v));
        end
    else
        print(SWS_ADDON_NAME..": "..tostring(text));
    end
end;

Utils.PrintError = function(err)
    Utils.Print("|cffff0000"..err.."|r");
end;

Utils.Try = function(tryFunc, catchFunc)
    local ok, err_or_ret = pcall(tryFunc);
    if(ok) then
        return err_or_ret;
    else
        if(catchFunc) then
            catchFunc(err_or_ret);
        end
    end
end;

Utils.SplitString = function(str, pattern)
    pattern = pattern or "[^%s]+";
    if pattern:len() == 0 then pattern = "[^%s]+" end;
    local parts = {__index = table.insert};
    setmetatable(parts, parts);
    str:gsub(pattern, parts);
    setmetatable(parts, nil);
    parts.__index = nil;
    return parts;
end;

-- workaround for curse localization generator
Utils.UnescapeUnicode = function(s)
    local ch = {
        ["\\a"] = '\\007', --'\a' alarm             Ctrl+G BEL
        ["\\b"] = '\\008', --'\b' backspace         Ctrl+H BS
        ["\\f"] = '\\012', --'\f' formfeed          Ctrl+L FF
        ["\\n"] = '\\010', --'\n' newline           Ctrl+J LF
        ["\\r"] = '\\013', --'\r' carriage return   Ctrl+M CR
        ["\\t"] = '\\009', --'\t' horizontal tab    Ctrl+I HT
        ["\\v"] = '\\011', --'\v' vertical tab      Ctrl+K VT
        ["\\\n"] = '\\010',--     newline
        ["\\\\"] = '\\092',--     backslash
        ["\\'"] = '\\039', --     apostrophe
        ['\\"'] = '\\034', --     quote
    };

    return s
        :gsub("(\\.)", ch)
        :gsub("\\(%d%d?%d?)", function(n)
            return string.char(tonumber(n))
        end);
end;