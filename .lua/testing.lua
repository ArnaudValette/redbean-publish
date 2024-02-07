-- testing.lua
local function test(parse)
   print("test 1:")
   test1 = parse('* Heading')
   print(test1.type==1)
   print(test1.text=="Heading")
   print(test1.level==1)

   print("test 2:")
   test2 = parse('** Heading')
   print(test2.type==1)
   print(test2.text=="Heading")
   print(test2.level==2)

   print("test 3:")
   test3 = parse(' ** paragraph bad shape')
   print(test3.type==0)
   print(test3.text=="** paragraph bad shape")
   print(test3.level==0)

   print("test 4:")
   test4 = parse(' - malformatted list')
   print(test4.type==0)
   print(test4.text=="- malformatted list")
   print(test4.level==0)

   print("test 5:")
   test5 = parse('  - list')
   print(test5.type==2)
   print(test5.text=="list")
   print(test5.level==1)

   print("test 6:")
   test6 = parse('- list')
   print(test6.type==2)
   print(test6.text=="list")
   print(test6.level==0)

   print("test 7:")
   test7 = parse('paragraph')
   print(test7.type==0)
   print(test7.text=="paragraph")
   print(test7.level==0)

   print("test 8:")
   test8 = parse('#+begin_src js')
   print(test8.type==3)
   print(test8.text=="js")
   print(test8.level==0)

   print("test 9:")
   test9 = parse('#+begin_verse')
   print(test9.type==4)
   print(test9.text=="")
   print(test9.level==0)

   print("test 10:")
   test10 = parse('#+begin_example')
   print(test10.type==7)
   print(test10.text=="")
   print(test10.level==0)

   print("test 11:")
   test11 = parse('#+begin_quote')
   print(test11.type==5)
   print(test11.text=="")
   print(test11.level==0)

   print("test 12:")
   test12 = parse('#+begin_')
   print(test12.type==10)
   print(test12.text=="")
   print(test12.level==0)

   print("test 13:")
   test13 = parse('#+end_src')
   print(test13.type==11)
   print(test13.text=="src")
   print(test13.level==0)
end

return {
   test = test
}
