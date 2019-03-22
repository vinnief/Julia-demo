#!julia.exe
## from https://en.wikibooks.org/wiki/Introducing_Julia/Plotting

using Plots; gr()
using PyPlot
fruit = ["peaches", "plums", "blueberries", "strawberries", "bananas"];
bushels = [100, 32, 180, 46, 21];
pie(x = fruit, y = bushels, holesize = 25)

PKG add Plots PyPlot GR UnicodePlots
using Plots
using Astro # you'll need to add this package with:  add https://github.com/cormullion/Astro.jl
using Dates
days = Dates.datetime2julian.(Dates.DateTime(2018, 1, 1, 0, 0, 0):Dates.Day(1):Dates.DateTime(2018, 12, 31, 0, 0, 0))
eq_values = map(equation_time, days)
plot(eq_values)
unicodeplots()
plot(eq_values)
gr();
plot(eq_values)
pyplot()
equation(d) = -7.65 * sind(d) + 9.87 * sind(2d + 206);
plot(equation, 1:365)
plot(eq_values);
plot!(equation, 1:365)
days = Dates.DateTime(2018, 1, 1, 0, 0, 0):Dates.Day(1):Dates.DateTime(2018, 12, 31, 0, 0, 0)
datestrings = Dates.format.(days, "u dd")
plot!(
    eq_values,

    label  = "equation of time (calculated)",
    line=(:black, 0.5, 6, :solid),

    size=(800, 600),

    xticks = (1:14:366, datestrings[1:14:366]),
    yticks = -20:2.5:20,

    ylabel = "Minutes faster or slower than GMT",
    xlabel = "day in year",

    title  = "The Equation of Time",
    xrotation = rad2deg(pi/3),

    fillrange = 0,
    fillalpha = 0.25,
    fillcolor = :lightgoldenrod,

    background_color = :ivory
    )
    ##
Pkg add UnicodePlots
using UnicodePlots
myPlot = lineplot([1, 2, 3, 7], [1, 2, -5, 7], title="My Plot", border=:dotted)
using VegaLite
x = [0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9]
y = [28, 43, 81, 19, 52, 24, 87, 17, 68, 49, 55, 91, 53, 87, 48, 49, 66, 27, 16, 15]
g = [0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1]

a = areaplot(x = x, y = y, group = g, stacked = true)
colorscheme!(a, ("Reds", 3))
