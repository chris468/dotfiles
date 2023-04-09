local if_ext = require("chris468.util.if-ext")
if_ext("neotest", function(neotest)
    local adapter_names = { "neotest-python", "neotest-dotnet" }
    local adapters = {}
    for _, n in ipairs(adapter_names) do
        if_ext(n, function(a)
            adapters[#adapters + 1] = a
        end)
    end

    local symbols = require("chris468.util.symbols")
    neotest.setup({
        adapters = adapters,
        icons = {
            passed = symbols.passed,
            failed = symbols.failed,
            skipped = symbols.skipped,
            running_animated = symbols.progress_animation,
        },
    })
end)
