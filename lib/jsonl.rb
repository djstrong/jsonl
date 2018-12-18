require 'jsonl/version'
require 'json'
require "forwardable"

class JSONL

  def initialize(data)
    @io = data.is_a?(String) ? StringIO.new(data) : data
  end

  def self.open(filename, mode="r", **options)
    begin
      f = File.open(filename, mode, options)
      jsonl = new(f)
    rescue Exception
      f.close
      raise
    end

    if block_given?
      begin
        yield jsonl
      ensure
        jsonl.close
      end
    else
      jsonl
    end
  end

  include Enumerable

  def each
    if block_given?
      @io.each_line do |line|
        yield JSON.parse(line)
      end
    else
      to_enum
    end
  end

  def <<(obj)
    @io << JSON.generate(obj)
    @io << "\n"
    self  # for chaining
  end

  extend Forwardable
  def_delegators :@io, :binmode, :binmode?, :close, :close_read, :close_write,
                 :closed?, :eof, :eof?, :external_encoding, :fcntl,
                 :fileno, :flock, :flush, :fsync, :internal_encoding,
                 :ioctl, :isatty, :path, :pid, :pos, :pos=, :reopen,
                 :seek, :stat, :string, :sync, :sync=, :tell, :to_i,
                 :to_io, :truncate, :tty?

  # Generate a string formatted as JSONL from an array.
  #
  # ==== Attributes
  #
  # * +objs+ - an array consists of objects
  # * +opts+ - options passes to `JSON.generate`
  #
  # ==== Exapmles
  #
  #   users = User.all.map(&:attributes) #=> [{"id"=>1, "name"=>"Gilbert", ...}, {"id"=>2, "name"=>"Alexa", ...}, ...]
  #   generated = JSONL.generate(users)
  #
  def self.generate(objs, opts = nil)
    unless objs.is_a?(Array)
      raise TypeError, "can't generate from #{objs.class}"
    end

    generated = []
    objs.map do |obj|
      generated << JSON.generate(obj, opts)
    end
    generated.join("\n")
  end

  # Parse JSONL string and return as an array.
  #
  # ==== Attributes
  #
  # * +source+ - a string formatted as JSONL
  # * +opts+ - options passes to `JSON.parse`
  #
  # ==== Examples
  #
  #   source = File.read('source.jsonl')
  #   parsed = JSONL.parse(source)
  #
  def self.parse(source, opts = {})
    parsed = []
    source.each_line do |line|
      parsed << JSON.parse(line, opts)
    end
    parsed
  end
end
