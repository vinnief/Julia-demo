# from https://juliacomputing.com/blog/2016/09/28/knn-char-recognition.html
# Read training set
trainLabels = readtable("$(path)/trainLabels.csv")
counts = by(trainLabels, :Class, nrow);
plot(x = counts[:Class], y = counts[:x1], color = counts[:Class], Theme(key_position = :none), Guide.xlabel("Characters")
# calculate distances
@manipulate for i = 1:size(trainLabels,1)
    load("$(path)/trainResized/$i.Bmp")
end

for i = 1 to m
    distance = d(X(i), x)
end
function get_all_distances(imageI::AbstractArray, x::AbstractArray)
    diff = imageI .- x
    distances = vec(sum(diff .* diff,1))
end
function get_k_nearest_neighbors(x::AbstractArray, imageI::AbstractArray, k::Int = 3, train = true)
    nRows, nCols = size(x)
    distances = get_all_distances(imageI, x)
    sortedNeighbors = sortperm(distances)
    if train
        return kNearestNeighbors = Array(sortedNeighbors[2:k+1])
    else
        return kNearestNeighbors = Array(sortedNeighbors[1:k])
    end
end
function assign_label(x::AbstractArray, y::AbstractArray{Int64}, imageI::AbstractArray, k, train::Bool)
    kNearestNeighbors = get_k_nearest_neighbors(x, imageI, k, train)
    counts = Dict{Int, Int}()
    highestCount = 0
    mostPopularLabel = 0
    for n in kNearestNeighbors
        labelOfN = y[n]
        if !haskey(counts, labelOfN)
            counts[labelOfN] = 0
        end
        counts[labelOfN] += 1
        if counts[labelOfN] > highestCount
            highestCount = counts[labelOfN]
            mostPopularLabel = labelOfN
        end
     end
    mostPopularLabel
end
for k  = 3:5
    checks = trues(size(train_data, 2))
    @time for i = 1:size(train_data, 2)
        imageI = train_data[:,i]
        checks[i]  = (assign_label(train_data, trainLabelsInt, imageI, k, true) == trainLabelsInt[i])
    end
    accuracy = length(find(checks)) / length(checks)
    @show accuracy
end
#Testing
x = test_data
xT = train_data
yT = trainLabelsInt
k = 3, #say
prediction = zeros(Int,size(x,2))
@time for i = 1:size(x,2)
    imageI = x[:,i]
    prediction[i]  = assign_label(xT, yT, imageI, k, false)
end
##
#The macro @parallel will split the iteration space amongst
#the available Julia processes and then perform the computation in each process simultaneously.
addprocs(n)
@time sumValues = @parallel (+) for i in 1:size(xTrain, 2)
    assign_label(xTrain, yTrain, k, i) == yTrain[i, 1]
end
##The ArrayFire package enables us to run computations on various general purpose
# GPUs from within Julia programs. The AFArray constructor from this package converts
#Julia vectors to ArrayFire Arrays, which can be transferred to the GPU. Converting Arrays
# to AFArrays allows us to trivially use
#the same code as above to run our computation on the GPU.

checks = trues(AFArray{Bool}, size(train_data, 2))
train_data = AFArray(train_data)
trainLabelsInt = AFArray(trainLabelsInt)
for k  = 3:5
    @time for i = 1:size(train_data, 2)
        imageI = train_data[:,i]
        checks[i]  = (assign_label(train_data, trainLabelsInt, imageI, k, true) == trainLabelsInt[i])
    end
    accuracy = length(find(checks)) / length(checks)
    @show accuracy
end
