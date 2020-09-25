#!/home/s1/bin/julia
#filesearch.jl
using JSON, DocOpt, Random, DataFrames, CSV, Match

export main
doc="""fileSearch.

Usage: 
  fileSearch.jl [--path <path>] [--filter <filter>] [--random <random>] [--save <savefile>] [--pics <picsdir>] [--last <last>] 
  fileSearch.jl --help 
  fileSearch.jl --version

Options:
  -H --help                Show this screen
  -V --version             Show version
  -P --path=<path>         Path for search [default: ./ ]
  -F --filter=<filter>     Regex to filter 
  -R --random=<random>     Randomly pick files from search
  -S --save=<savefile>     File to save search results 
  --pics=<picsdir>      Create a pictures dir
  -L --last=<last>        Return last <count> dated files
  Note: If --last and --random are both selected, <random> files are selected from the <last> files
"""

#kwargs
Base.@kwdef mutable struct Options
  path::String=""
  filter=r".*\.mp4"
  random::Union{Int,Nothing}=nothing
  save=false
  pics::Union{String,Nothing}=nothing
  last::Union{Int,Nothing}=nothing
end

"Set values of Option to match command line flags"
function setup!(flag::String, value::Any,  opt::Options)  
  @match (flag, value)  begin
  ("--path"   || "-P",  p::String) => (opt.path=p;println("Path set to $(opt.path)"))
  ("--filter" || "-F",  f::String) => (opt.filter=Regex(f))
  ("--random" || "-R",  r::String) => (opt.random=parse(Int64, r);println("Picking $r random files"))
  ("--save"   || "-S",  s::String) => (opt.save=s)
  ("--pics" ,           p::String) => (opt.pics=p)
  ("--last"   || "-L",  l::String) => (opt.last=parse(Int64, l);println("Picking last $l files"))
#  bad                     => println("Unknown argument: $bad")
  end
end

"Gets all the file names in a directory tree"
function getAllFiles(path;ignore_hidden=true)
  root, dirs, files = first(walkdir(path;follow_symlinks=true))
  allFiles = map(f -> joinpath(path, f), files)
  for dir in dirs 
    if ignore_hidden && dir[1] == '.' continue end
    dirFiles=getAllFiles(joinpath(root, dir))
    append!(allFiles, dirFiles)
  end
  allFiles
end

function write(files, options)
  shFile=joinpath(options.path, "vlc.sh")
  count=length(files)
  println("Writing $count files to $shFile")
  open(shFile, "w") do io 
    println(io, "#!/bin/bash")
    for fname in files
      pFile="file:///" * "'" * fname * "'"
      rs="vlc $pFile &"
      println(io, rs)
    end
  end
  chmod(shFile, 0o777)
end

function getRandom(files, options) 
  randomFiles=[]
  for r in 1:options.random
    r=rand(1:size(files)[1])
#    println("Random file: $r")
    push!(randomFiles, files[r])
  end
  randomFiles
end

getFileCTime(file)=(ctime(stat(file)), file)
getFileTimes(allFiles)=map(getFileCTime, allFiles)

"Get the last created files by timestamp"
function getLast(files, options)
  fileTimes=map(getFileCTime, files)
  sortFiles=sort(fileTimes, rev=true)
  lastFiles=[sortFiles[r][2] for r in 1:options.last]
  #println(lastFiles)
  lastFiles
end

is(something)=!isnothing(something)

function main()
  options=Options()
  args=docopt(doc)
  [setup!(arg.first, arg.second, options) for arg in args]
  println("Options: $options")
  allFiles=getAllFiles(options.path)
  isMatch(str)=!isnothing(match(options.filter, str))
  filterFiles=filter(isMatch, allFiles)
  fileLength=size(filterFiles)[1]
  println("There are $(fileLength) files in the directory tree. ")
  if fileLength == 0
    println("No files found in path. Exiting")
    exit()
  end

  writeFiles=filterFiles
  if is(options.last)
    writeFiles=getLast(filterFiles, options)  
    println("Selected last $(length(writeFiles)) files")
    if is(options.random)
      writeFiles=getRandom(writeFiles, options)
      println("Selected last random $(length(writeFiles)) file")
    end
  elseif is(options.random)
    writeFiles=getRandom(filterFiles, options)
  end
  if (is(options.random) || is(options.last)) write(writeFiles, options)  end
#  if !isnothing(options.save) CSV.write(options.save, allFiles) end
end

main()
#args=docopt(doc)
#println(args)
