for n=2:10
   print("n is ", n)
   x=0
   y=1
   print(": ",y)
   for i=1:20
      x+=y
      y+=x
     print(' ', x%n, ' ', y%n)
   end
   println()
end
###
function findlength2(a, n)
   k=3
   while (k<length(a))&&  (((a[k-1]%n)!=a[1])  ||  ((a[k]%n)!=a[2])) k+=1 end
   finished= (k<=length(a))&&  ((a[k-1]%n==a[1])  &&  ((a[k]%n)==a[2]))
   return finished,k
end
function fibountil2n(n)
  x=big(1)
  y=1
  a=[x,y]
  repr(a)
  for i=1:n
     x+=y
     y+=x
     a
     push!( a,x,y)
  end
  a
end

a=fibountil2n(29)
#println(transpose(a))
for n=2:20
  global a
  print("modulo ", n, ' ')
  finished, k=findlength2(a,n)
  if finished
      println("cycle length ",k)
  else println("found no cycle, tried until cycle length of ", length(a)-1)
  end
end
##########
using Plots; gr()
histogram(randn(10000), nbins=100)

function areaofcircle()
            print("What's the radius?")
            r = parse(Float64, readline(stdin))
            print("a circle with radius $r has an area of:")
            println(π * r^2)
end
areaofcircle() # input only works if you are in the REPL already before.

##
function showtypetree(T, level=0)
     println("\t" ^ level, T)
     for t in subtypes(T)
         showtypetree(t, level+1)
    end
 end

 showtypetree(Number)
 # doesnt work: showtypetree(AbstractString)
