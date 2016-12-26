require_relative 'file_ops'
# Structure class defines an atomic structure.
class Structure
  attr_accessor :title, :cell_info, :coord_type, :num_atoms, :atom_names,
                :atom_coors, :space_group, :supercell, :cell_type

  def initialize(filename = "olcao.skl")
    case File.extname(filename)
    when '.skl'
      init_from_skl(filename)
    else
      puts "unable to handle file ext: #{File.extname(filename)}"
    end
  end

  def init_from_skl(filename)
    struct = Skl.new(filename)
    @title = struct.title
    @cell_info = struct.cell_info
    @coord_type = struct.coord_type
    @num_atoms = struct.num_atoms
    @atom_names = struct.atom_names
    @atom_coors = struct.atom_coors
    @space_group = struct.space_group
    @supercell = struct.supercell
    @cell_type = struct.cell_type
  end

  def real_lattice_matrix
    @real_lattice_matrice ||= make_real_lattice_matrix
  end

  def real_lattice_matrix_inv
    @real_lattice_matrice_inv ||= make_real_lattice_matrix_inv
  end

  private

  def make_real_lattice_matrix
    a, b, c = @cell_info.values_at("a", "b", "c")
    # Convert the angles to radians.
    alpha = @cell_info["alpha"] * Math::PI / 180
    beta = @cell_info["beta"] * Math::PI / 180
    gamma = @cell_info["gamma"] * Math::PI / 180
    # Start the construction of the RLM, the real lattice array.
    rlm = Array.new(3) { Array.new(3) }
    # Assume that a and x are coaxial.
    rlm[0][0], rlm[0][1], rlm[0][2] = a, 0.0, 0.0
    # b is then in the xy-plane.
    rlm[1][0], rlm[1][1], rlm[1][2] = b * Math.cos(gamma), b*Math.sin(gamma), 0.0
    # c is a mix of x,y, and z directions.
    rlm[2][0] = (c * Math.cos(beta))
    rlm[2][1] = (c * (Math.cos(alpha) - Math.cos(gamma) * Math.cos(beta)) /
                  Math.sin(gamma))
    rlm[2][2] = (c * Math.sqrt(1.0 - Math.cos(beta)**2 -
                                ((rlm[2][1] / c)**2)))
    # now lets correct for numerical errors.
    (0...3).each do |i|
      (0...3).each do |j|
        rlm[i][j] = 0.0 if rlm[i][j] < 1e-8
      end
    end
    rlm
  end

  def make_real_lattice_matrix_inv
    a, b, c = @cell_info.values_at("a", "b", "c")
    # Convert the angles to radians.
    alpha = @cell_info["alpha"] * Math::PI / 180
    beta = @cell_info["beta"] * Math::PI / 180
    gamma = @cell_info["gamma"] * Math::PI / 180

    v = Math.sqrt(1.0 - (Math.cos(alpha) * Math.cos(alpha)) -
                  (Math.cos(beta) * Math.cos(beta)) -
                  (Math.cos(gamma) * Math.cos(gamma)) +
                  2.0 * Math.cos(alpha) * Math.cos(beta) * Math.cos(gamma))

    mlr = Array.new(3) { Array.new(3) }
    # assume a and x are colinear.
    mlr[0][0], mlr[0][1], mlr[0][2] = 1.0 / a, 0.0, 0.0
    # assume b in the xy-plane.
    mlr[1][0] = -Math.cos(gamma) / (a * Math.sin(gamma))
    mlr[1][1] = 1.0 / (b * Math.sin(gamma))
    mlr[1][2] = 0.0
    # c is then a mix of all three axes.
    mlr[2][0] = (Math.cos(alpha) * Math.cos(gamma) - Math.cos(beta)) /
                 (a * v * Math.sin(gamma))
    mlr[2][1] = (Math.cos(beta) * Math.cos(gamma) - Math.cos(alpha)) /
                 (b * v * Math.sin(gamma))
    mlr[2][2] = Math.sin(gamma) / (c * v)
    # now lets correct for numerical errors.
    (0...3).each do |i|
      (0...3).each do |j|
        mlr[i][j] = 0.0 if mlr[i][j] < 1e-8
      end
    end
    mlr
  end
end

f = Structure.new
p f.real_lattice_matrix
p f.real_lattice_matrix_inv
