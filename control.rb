class Structure

  attr_reader :title, :cellInfo, :coordType, :numAtoms

  def initialize filename
    if File.extname(filename) == ".skl"
      @title = getSklTitle filename
      @cellInfo = getSklCell filename
      @coordType = getSklCoordType filename
      @numAtoms = getSklNumAtoms filename
    end
  end

  private 

  def getSklTitle sklFile
    title = ""
    File.open(sklFile).each do |line|
      words = line.strip.split
      next if words[0] == "title"
      return title if words[0] == "end"
      title += words.join " "
    end
    abort("Could not find title in #{sklFile}")
  end

  def getSklCell sklFile
    info = Array.new
    foundCell = false
    File.open(sklFile).each do |line|
      words = line.strip.split
      if foundCell
        words.each do |entry|
          info.push entry.to_f
        end
        return info
      end
      foundCell = true if words[0] == "cell"
    end
    abort("Could not find cell information in #{sklFile}")
  end

  def getSklCoordType sklFile
    foundCell = false
    File.open(sklFile).each do |line|
      words = line.strip.split
      if foundCell
        next if words.length > 2
        return 'F' if words[0].include? 'frac'
        return 'C' if words[0].include? 'cart'
      end
      foundCell = true if words[0] == "cell"
    end
    abort("Could not find coordinate type in #{sklFile}")
  end

  def getSklNumAtoms sklFile
    foundCell = false
    File.open(sklFile).each do |line|
      words = line.strip.split
      if foundCell
        next if words.length > 2
        return words[1].to_i
      end
      foundCell = true if words[0] == "cell"
    end
    abort("Could not find number of atoms in #{sklFile}")
  end


end

f = Structure.new("olcao.skl")
puts f.title
puts f.cellInfo
puts f.coordType
puts f.numAtoms
