import Pkg

push!(LOAD_PATH, chomp(pwd()))
Pkg.add("findPrimes.jl")
using findPrimes

##test Dict making
@assert sumDivisors(28)==28+28
Divisors[28]
@assert(isPerfect(28))
Divisors
DivisorSum
@time([i for i = 1:500 if isPerfect(i)])

multiPerfect(28)

@assert PrimeDecomposition!(28,extend=false)==[2,2,7]
@assert factor!(28, true,false)[3]==[2]
@assert PrimeDecomposition!(28)==[2,2,7]
#does not need to extend variable primes if n<=(largest prime+2)^2, so not here yet
@assert PrimeDecomposition!(25)==[5,5] # even if not extended yet
@assert PrimeDecomposition!(21,extend=false)==[3,7]
@assert PrimeDecomposition!(35)==[5,7] # this added 5, not 7  !!
extendPrimes!(35)

prod7=2*3*5*7*11*13*17
prod8=prod7*19
prod11=prod8*23*29*31
extendPrimes!(prod7)
@time(PrimeDecomposition!(prod7,extend=false;primes=collect(2:prod7)))
@time(Divisors!(prod7)) #note: use collect(2:prod7)
@time(PrimeDecomposition!(prod7,extend=false,primes=collect(2:prod7))) #note: use collect(2:prod7)
pots=collect(2:20)
@time(PrimeDecomposition!(41*43,extend=true,debug=20,primes=collect(2:prod7)))
@time(factor!(prod7+1,true,false;potFactors=collect(2:(prod7+1))))
primes'
@assert primes==[2,3]
@assert factor!(28, true,true)[3] == [2,7]
@assert findOneFactor!(28)== 2 #7 not in primes yet
@assert PrimeDecomposition!(28)==[2,2,7] #
@assert PrimeDecomposition!(28)==[2,2,7] #returns [2,2,7]
PrimeDecomposition!(28)
PrimeDecomposition!(2*2*3*11)=[2,2,3,11],
# not meant to find 7 new primes, but finds some small prime anyway.
primes'
@assert PrimeDecomposition!(28)==[2,2,7] # this function adds new primes
primes'
@assert( Divisors!(28) ==[2,4,7,14,28])
@assert PrimeDecomposition!(2*2*3*7*7)==[2,2,3,7,7]#
#PrimeDecomposition!!(2*2*3*7*7)
@assert PrimeDecomposition!(17017)==[7,11,13,17]  #adds 11,13,17 to primes
@assert PrimeDecomposition!(prod7^2)==[2,2,3,3,5,5,7,7,11,11,13,13,17,17]
@assert
PrimeDecomposition!((prod7+1)^2)
==BigInt[]  #19,19,19,97,97,97,277,277,277 not yet found
@assert PrimeDecomposition!(prod7+1)==[19,97,277]  #adds primes up to 277
@assert PrimeDecomposition!((prod7+1)^2)==BigInt[19,19,97,97,277,277] #found
## now do some timing
@time( for n=4:46 println(n," ",PrimeDecomposition!(n)) end) # klopt!
@time( for n=4:46 println(n, factor!(n)[3]) end) #same thing!
@time( for n=4:20 println(n,factor!(n,true,potFactors=primes)) end)
# should find each factor exactly once! but finds n twice, sometimes.


@time(begin primes=[2,3];addPrime!(50,debug=3);primes' end)
@time(PrimeDecomposition!(prod7))
@time(PrimeDecomposition!(prod7+1))
@time(Divisors!(prod7+1))
@time(Divisors!(prod7+1))
PrimeDecomposition!(prod7+1)
print(primes')
@time(PrimeDecomposition!(prod7))
@time(addPrime!(24))
@time(addPrime!(25))
@time(addPrime!(25))
@time(addPrime!(25))
@time(addPrime!(200))
print(primes')

## test perfection
@assert isVeryPerfect(6)
@assert !isPerfect(29,2)

@time([i for i = 1:10000 if isPerfect(i)]) # takes 94 seconds on Acer2.
@time(begin n=100; print("Perfect numbers until ",n,": ");for i in 1:n isPerfect(i) end end)
# [1,6,28,496,8128]
@time(@assert begin n=1000; print("Perfect numbers until ",n,": ");
     [i for i in 1:n if isPerfect(i,0)==0]  end ==[1,6,28,496])
     # 0.141507 seconds (141.29 k allocations: 5.286 MiB)
primes=[2,3]
addPrime!(100)
@assert findDivisorswithMultiplicity!(28)==[1,2,2,4,7,14,14,28]
for i in 2:20
  list= findDivisorswithMultiplicity!(i)
  println(length(list)," divisors of ",i,": ", list )
end
@time(@assert begin n=1000; print("very Perfect numbers until ",n,": ");[i for i in 1:n if isVeryPerfect(i,debug=0)] end==[6])
#0.468230 seconds (226.86 k allocations: 77.772 MiB, 7.55% gc time)
@time(begin n=100; print("verysumdivisors numbers until ",n,": ");[ n for i in 1:n if isVeryPerfect(i)] end)
@time(  for i in 1:1001 if isVeryPerfect(i)==0 println(i, " is very perfect")end end)
# until 100001 was 145.212405 seconds (35.06 M allocations: 114.396 GiB, 11.57% gc time)
# only 6 is very perfect below 100001
@time( @assert [[n,amico(n)]  for n in 1:1001 if amico((n))!=0] ==[[1,1],[6,6],[28,28],[220,284],[284,220],[496,496]]) #36,55  not symmetric?
@time( @assert [[n,amico(n,cyclelength=3)]  for n in 1:1001 if amico(n,cyclelength=3)!=0]==[[6,6],[28,28],[496,496]])
@time( @assert [[n,amico(n,cyclelength=4)]  for n in 1:1001 if amico(n,cyclelength=4)!=0]==[[6,6],[28,28],[220,284],[284,220],[496,496]])
@time( [[n,amico(n,cyclelength=5)]  for n in 1:1001 if amico(n,cyclelength=5)!=0]==[[6,6],[28,28],[496,496]])
@time( [[n,amico(n,cyclelength=6)]  for n in 1:1001 if amico(n,cyclelength=6)!=0]==[[6,6],[28,28],[220,284],[284,220],[496,496]])
@time( [[n,amico(n,cyclelength=7)]  for n in 1:1001 if amico(n,cyclelength=7)!=0]==[[6,6],[28,28],[496,496]])
@time( [[n,amico(n,cyclelength=8)]  for n in 1:1001 if amico(n,cyclelength=8)!=0]==[[6,6],[28,28],[220,284],[284,220],[496,496]])
[[n,amico(n,cyclelength=8)]  for n in 1:10001 if amico(n,cyclelength=8)!=0]
@time( [[n,moltoamico(n,cyclelength=1)]  for n in 1:1001 if moltoamico(n,cyclelength=1)!=0]) # 0.799494 seconds
@time( [[n,moltoamico(n,cyclelength=2)]  for n in 1:1001 if moltoamico(n,cyclelength=2)!=0]==[[6,6],[20,34],[34,20],[765,963],[963,765]]) #16.942204
@time( [[n,moltoamico(n,cyclelength=3)]  for n in 1:1001 if moltoamico(n,cyclelength=3)!=0])==[[6,6]]
# 338.246336 seconds (2.59 G allocations: 66.644 GiB, 28.81% gc time)

@time( [[n,moltoamico(n,cyclelength=4)]  for n in 1:101 if moltoamico(n,cyclelength=4)!=0]==[[6,6],[20,34],[34,20]]) #2.594176
@time( [[n,moltoamico(n,cyclelength=4)]  for n in 1:1000 if moltoamico(n,cyclelength=4)!=0]) # ==[[6,6],[20,34],[34,20]]) #2.594176

@time( [[n,moltoamico(n,cyclelength=5)]  for n in 1:101 if moltoamico(n,cyclelength=5)!=0]) #22.695123
@time( [[n,moltoamico(n,cyclelength=6)]  for n in 1:101 if moltoamico(n,cyclelength=6)!=0])
@time( [[n,moltoamico(n,cyclelength=7)]  for n in 1:101 if moltoamico(n,cyclelength=7)!=0])
@time( [[n,moltoamico(n,cyclelength=8)]  for n in 1:101 if moltoamico(n,cyclelength=8)!=0])

@time( [n  for n in 1:101 if multiPerfect((n))])





## unittests
primes=[2,3]
isPrime(35)
isPrime!(35)
primes'

init(force=true)
extendPrimes!(1000;primesNeeded=3, method=1,debug=67)
primes'
@assert(isPrime(997)==true)
isPrime(1031)
addPrimesUntil!(30)
findNextPrime(method=1,debug = 5)#does not append them!
findNextPrime(method=2,debug=5)

factorUsing(4)
factorUsing(5)
factorUsing(6)
factorUsing(6)[3]
factorUsing(7)
factorUsing(8)
factorUsing(9)
factorUsing(10)
factorUsing(11)
factorUsing(23)
factorUsing(24)
factorUsing(25)
factorUsing(29)
factorUsing(125)
factorUsing(35)
findOneFactor!(6)
findOneFactor!(11)
findOneFactor!(79)
findOneFactor!(121)


@time addPrimesUntil!(43*41*42,debug=0)
primes'
using JLD
save("primes<=74027.jld", "primesuntil74027", primes)
datadict=load("primes.jld")
datadict["primesuntil74027"]==primes
datadict=[]

## unit tests of primedecompositions


PrimeDecomposition!(6,debug=0)
PrimeDecomposition!(11,extend=false,primes=primes,debug=10)
PrimeDecomposition!(35,extend=false,primes=primes,debug=10)
PrimeDecomposition!(11,debug=0)
primes'
PrimeDecomposition!(35,debug=10)
primes'

PrimeDecomposition!(77,debug=10)
primes'
PrimeDecomposition!(997,debug=10)
PrimeDecomposition!(60)
Divisors!(60)
primes'
addPrimesUntil!(40,method=2)
addPrime!(1,method=1,primes=primes,debug=0)
addPrime!(1,method=2)
addPrime!(1,method=2,debug=7)

for i=1:2
  print( "method $i ");@time(begin global primes=[2,3];extendPrimes!(5000; method= i, primes=primes);primes' end)
end

for i=1:2
  print( "method ",i," ");@time(begin global primes=[2,3];addPrime!(5000;method= i, primes=primes);primes' end)
end
primes1=[2,3]; primes2=[2,3];
addPrime!(5000, method=1, primes=primes1)
addPrime!(5000, method=2, primes=primes2)
@assert primes1==primes2
@assert countClingy(3)==(1,2,2,[3,1,1])
@assert countClingy(3)[1]==1
@assert countClingy(31)[1]==1
#===========================
method 1   1.024183 seconds (104.58 k allocations: 1006.703 MiB, 15.00% gc time)
method 2   1.265096 seconds (245.81 k allocations: 1.469 GiB, 18.77% gc time)
it seemed in earlier versions isPrime was the best way of just searching for primes.:
not much less time but hugely less memory: some hundred MB instead of 1 GB
===========================#
