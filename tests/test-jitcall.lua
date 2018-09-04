local sljit = require "sljit"
local jitcall = require "jitcall"

-- Magic numbers for x/17.
local mul, sh1, sh2 = 0xe1e1e1e2, 1, 4

local compiler = sljit.create_compiler()

compiler:emit_enter{arg_types=sljit.declare("SW"), saveds=1, scratches=1}
    :emit_op2('MUL',   'R0', 'S0', sljit.imm(mul))
    :emit_op2('LSHR',  'R0', 'R0', sljit.imm(32))
    :emit_op2('SUB32',  'S0', 'S0', 'R0')
    :emit_op2('LSHR32', 'S0', 'S0', sljit.imm(sh1))
    :emit_op2('ADD32',  'R0', 'R0', 'S0')
    :emit_op2('LSHR32', 'R0', 'R0', sljit.imm(sh2))
	:emit_return('MOV', 'S0', 0)
	
-- Pick any line you like. Or don't. Two returns don't make any harm.
-- sljit.emit_return(compiler, 'MOV', 'R0', 0)

local code = compiler:generate_code()
print("code size: " .. code:size())

jitcall.disassemble(code)

local z = 17 * 16 + 8
print(string.format("%d / 17 = %d", z, jitcall.call(code, z)))
