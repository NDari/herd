class Skl
  def initialize(filepath = "olcao.skl")
    @filepath = filepath
  end

  def title
    @title ||= process_title
  end

  def cell_info
    @cell_info ||= process_cell_info
  end

  def coord_type
    @coord_type ||= process_coord_type
  end

  def num_atoms
    @num_atoms ||= process_num_atoms
  end

  def atom_names
    @atom_names ||= process_atom_info('names')
  end

  def atom_coors
    @atom_coors ||= process_atom_info('coors')
  end

  def space_group
    @space_group ||= process_space_group
  end

  def supercell
    @supercell ||= process_supercell
  end

  def cell_type
    @cell_type ||= process_cell_type
  end

  private

  def process_title
    skl_file = File.open(@filepath, 'r')
    string = skl_file.readline
    raise "the first line in .skl is not 'title\n'" if string != "title\n"
    title = ''
    loop do
      words = skl_file.readline.strip.split
      break if words.length == 1 && words[0] == 'end'
      title += words.join(' ')
    end
    skl_file.close
    title
  end

  def process_cell_info
    skl_file = File.open(@filepath, 'r')
    HelperFunctions.read_to_tag(skl_file, 'cell')
    cell_info = {}
    words = skl_file.readline.strip.split
    infos = %w(a b c alpha beta gamma)
    (0..5).each { |i| cell_info[infos[i]] = words[i].to_f }
    skl_file.close
    cell_info
  end

  def process_coord_type
    skl_file = File.open(@filepath, 'r')
    HelperFunctions.read_to_tag(skl_file, 'cell')
    skl_file.readline
    words = skl_file.readline.strip.split
    skl_file.close
    return 'F' if words[0] =~ /frac/i
    return 'C' if words[0] =~ /cart/i
    raise "Unknown coordinate type found in file."
  end

  def process_num_atoms
    skl_file = File.open(@filepath, 'r')
    HelperFunctions.read_to_tag(skl_file, 'cell')
    skl_file.readline
    num_atom = skl_file.readline.strip.split[1].to_i
    skl_file.close
    num_atom
  end

  def process_atom_info(want)
    skl_file = File.open(@filepath, 'r')
    HelperFunctions.read_to_tag(skl_file, 'cell')
    (2).times { skl_file.readline }
    info = {}
    (0...@num_atoms).each do |i|
      words = skl_file.readline.strip.split
      (info[i] = words[0]) if want == 'names'
      (info[i] = [words[1].to_f, words[2].to_f, words[3].to_f]) if want == 'coors'
    end
    skl_file.close
    info
  end

  def process_space_group
    skl_file = File.open(@filepath, 'r')
    HelperFunctions.read_to_tag(skl_file, 'cell')
    (2+@num_atoms).times { skl_file.readline }
    space_group = skl_file.readline.strip.split[1]
    skl_file.close
    space_group
  end

  def process_supercell
    skl_file = File.open(@filepath, 'r')
    HelperFunctions.read_to_tag(skl_file, 'cell')
    (3+@num_atoms).times { skl_file.readline }
    words = skl_file.readline.strip.split
    skl_file.close
    sc = {}
    sc[0], sc[1], sc[2] = words[1].to_f, words[2].to_f, words[3].to_f
    sc
  end

  def process_cell_type
    skl_file = File.open(@filepath, 'r')
    HelperFunctions.read_to_tag(skl_file, 'cell')
    (4+@num_atoms).times { skl_file.readline }
    words = skl_file.readline.strip.split
    skl_file.close
    return "F" if words[0] == "full"
    return "P" if words[0] == "prim"
    raise "Unknown cell type encountered #{words[0]}"
  end
end

class HelperFunctions
  def self.read_to_tag(opened_file, tag)
    opened_file.rewind
    opened_file.each_line do |line|
      words = line.strip.split
      return if words.length == 1 && words[0] == tag
    end
    raise "Read the file but did not file the tag #{tag}"
  end
end
