require "ffi"
require "rrd/version"
require "rrd/wrapper"
require "rrd/base"
require "rrd/graph"
require "rrd/builder"
require "rrd/ext/fixnum"

module RRD
  extend self
  
  BANG_METHODS = [:graph!]
  
  def graph(image_file, options = {}, &block)
    graph = Graph.new(image_file, options)
    graph.instance_eval(&block)
    graph.save
  end
  
  def error
    Wrapper.error
  end
  
  def to_line_parameters(hash, known_flags = [])
    used_flags = []
    known_flags.each do |flag|
      used_flags << "--#{flag}".gsub(/_/, "-") if hash.delete(flag)
    end
    
    line_params = Hash[*hash.reduce([]) { |result, (key,value)| result += ["--#{key}".gsub(/_/, "-"), value.to_s] }]
    params = line_params.keys.sort.reduce([]) { |result, key| result += [key, line_params[key]] }
    used_flags + params
  end
  
  def methods
    super + BANG_METHODS
  end
  
  def bang(method, *args, &block)
    result = send(method, *args, &block)
    raise error unless result
    result
  end

  # Defining all bang methods
  BANG_METHODS.each do |bang_method|
    define_method(bang_method) do |*args, &block|
      method = bang_method.to_s.match(/^(.+)!$/)[1]
      bang(method, *args, &block)
    end
  end
end

