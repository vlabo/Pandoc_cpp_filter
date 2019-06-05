--- MIT License (MIT)
--- Copyright (c) 2019. Vladimir Stoilov
--- Permission is hereby granted, free of charge, to any person obtaining a copy
--- of this software and associated documentation files (the "Software"), to deal
--- in the Software without restriction, including without limitation the rights
--- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--- copies of the Software, and to permit persons to whom the Software is
--- furnished to do so, subject to the following conditions:
--- The above copyright notice and this permission notice shall be included in
--- all copies or substantial portions of the Software.
--- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
--- THE SOFTWARE.

--- File        : cpp.lua
--- Author      : Vladimir Stoilov
--- Description : Compiles and runs and prints the result of c++ code inside markdown document.

cppError = ""
globalCode = ""

local function has_value (tab, val)
   for index, value in ipairs(tab) do
      if value == val then
	 return true
      end
   end

   return false
end

cppExec = {	
   CodeBlock = function(el)
      cppError = ""
      local out = ""

      local isGlobal = false
      local hide = false
      local ignore = false
      
      if not has_value( el.classes, "cpp") then
	 return el
      end
            
      if el.attributes["ignore"] == "true" then
	 ignore = true
      end

      if el.attributes["global"] == "true" then
	 isGlobal = true
      end

      if el.attributes["hide"] == "true" then
	 hide = true
      end
      
      if not ignore and not isGlobal then
	 local cppFileName = '/tmp/pandoc_tmp.cpp'  
	 local f = io.open( cppFileName, 'w')
	 f:write(globalCode)
	 f:write("\n")
	 f:write(el.text)
	 f:close()

	 local exeName = '/tmp/pandoc_cpp_tmp'
	 cppError = pandoc.pipe('g++', {cppFileName, '-o', exeName}, '')
	 if cppError == "" then
	    out = pandoc.pipe(exeName, {}, '')
	 else
	    print(cppError)
	 end

	 pandoc.pipe('rm', {cppFileName, exeName}, '')
      end

      if isGlobal and not ignore then
	 globalCode = globalCode .. "\n" .. el.text
      end
      
      local result = {}

      if not hide then
	 table.insert(result, el)
      end

      if out ~= "" then
	 table.insert(result, pandoc.Para({pandoc.Strong("Result: "), pandoc.Str(out)})) 
      end
      
      return result
   end,
}

function Pandoc(el)
   local div = pandoc.Div(el.blocks)
   local pan = pandoc.walk_block(div, cppExec).content
   return pandoc.Pandoc(pan, el.meta)
end
	   

