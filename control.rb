# Structure class defines an atomic structure.
class Structure
  attr_accessor :title, :cell_info, :coord_type, :num_atoms, :atom_names,
                :atom_coors, :space_group, :super_cell, :cell_type, :rlm, :mlr

  def initialize(filename = 'olcao.skl')
    case File.extname(filename)
    when '.skl'
      init_from_skl(filename)
    else
      puts "unable to handle file ext: #{File.extname(filename)}"
    end
  end

  def init_from_skl(filename)
    skl_file = File.open(filename, 'r')
    skl_title(skl_file) # set @title
    skl_cell_info(skl_file) # set @cell_info
    skl_coord_type_and_num_atoms(skl_file) # set @coord_type and @num_atoms
    skl_atom_info(skl_file) # set @atom_names and @atom_coors
    # real_lattice_matrix
    # real_lattice_matrix_inv
  end

  # def real_lattice_matrix
  #   a = @cell_info[0]
  #   b = @cell_info[1]
  #   c = @cell_info[2]
  #   # Convert the angles to radians.
  #   alf = @cell_info[3] * Math::PI / 180
  #   bet = @cell_info[4] * Math::PI / 180
  #   gam = @cell_info[5] * Math::PI / 180
  #   # Start the construction of the RLM, the real lattice array.
  #   @rlm = Array.new(3) { Array.new(3) }
  #   # Assume that a and x are coaxial.
  #   @rlm[0][0] = a
  #   @rlm[0][1] = 0.0
  #   @rlm[0][2] = 0.0
  #   # b is then in the xy-plane.
  #   @rlm[1][0] = (b * Math.cos(gam))
  #   @rlm[1][1] = (b * Math.sin(gam))
  #   @rlm[1][2] = 0.0
  #   # c is a mix of x,y, and z directions.
  #   @rlm[2][0] = (c * Math.cos(bet))
  #   @rlm[2][1] = (c * (Math.cos(alf) - Math.cos(gam) * Math.cos(bet)) /
  #                 Math.sin(gam))
  #   @rlm[2][2] = (c * Math.sqrt(1.0 - Math.cos(bet)**2 -
  #                               ((@rlm[2][1] / c)**2)))
  #   # now lets correct for numerical errors.
  #   (0...3).each do |i|
  #     (0...3).each do |j|
  #       @rlm[i][j] = 0.0 if @rlm[i][j] < 1e-8
  #     end
  #   end
  # end

  # def real_lattice_matrix_inv
  #   a = @cell_info[0]
  #   b = @cell_info[1]
  #   c = @cell_info[2]
  #   # Convert the angles to radians.
  #   alf = @cell_info[3] * Math::PI / 180
  #   bet = @cell_info[4] * Math::PI / 180
  #   gam = @cell_info[5] * Math::PI / 180

  #   v = Math.sqrt(1.0 - (Math.cos(alf) * Math.cos(alf)) -
  #                 (Math.cos(bet) * Math.cos(bet)) -
  #                 (Math.cos(gam) * Math.cos(gam)) +
  #                 2.0 * Math.cos(alf) * Math.cos(bet) * Math.cos(gam))

  #   @mlr = Array.new(3) { Array.new(3) }

  #   # assume a and x are colinear.
  #   @mlr[0][0] = 1.0 / a
  #   @mlr[0][1] = 0.0
  #   @mlr[0][2] = 0.0

  #   # assume b in the xy-plane.
  #   @mlr[1][0] = -Math.cos(gam) / (a * Math.sin(gam))
  #   @mlr[1][1] = 1.0 / (b * Math.sin(gam))
  #   @mlr[1][2] = 0.0

  #   # c is then a mix of all three axes.
  #   @mlr[2][0] = (Math.cos(alf) * Math.cos(gam) - Math.cos(bet)) /
  #                (a * v * Math.sin(gam))
  #   @mlr[2][1] = (Math.cos(bet) * Math.cos(gam) - Math.cos(alf)) /
  #                (b * v * Math.sin(gam))
  #   @mlr[2][2] = Math.sin(gam) / (c * v)

  #   # now lets correct for numerical errors.
  #   (0...3).each do |i|
  #     (0...3).each do |j|
  #       @mlr[i][j] = 0.0 if @mlr[i][j] < 1e-8
  #     end
  #   end
  # end

  private

  def skl_title(skl_file)
    @title = ''
    skl_file.readline
    loop do
      words = skl_file.readline.strip.split
      break if words.length == 1 && words[0] == 'end'
      @title += words.join(' ')
    end
  end

  def skl_cell_info(skl_file)
    @cell_info = {}
    skl_file.readline
    infos = %w(alpha beta gamma a b c)
    words = skl_file.readline.strip.split
    (0..5).each { |i| @cell_info[infos[i]] = words[i].to_f }
  end

  def skl_coord_type_and_num_atoms(skl_file)
    words = skl_file.readline.strip.split
    @coord_type = 'F' if words[0] =~ /frac/i
    @coord_type = 'C' if words[0] =~ /cart/i
    @num_atoms = words[1].to_i
  end

  def skl_atom_info(skl_file)
    @atom_coors = {}
    @atom_names = {}
    (0...@num_atoms).each do |i|
      words = skl_file.readline.strip.split
      @atom_names[i] = words[0]
      @atom_coors[i] = [words[1].to_f, words[2].to_f, words[3].to_f]
    end
  end
end

f = Structure.new
p f.title
p f.cell_info
p f.coord_type
p f.num_atoms
p f.atom_names
p f.atom_coors[0]
p f.atom_coors[0][0]
# p f.mlr
# p f.rlm
