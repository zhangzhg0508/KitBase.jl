using PyCall

# try importing meshio
# catch the installation
# 1) Julia built-in miniconda
# 2) global pip installer
try
    cmd = `pip3 install meshio --user`
    run(cmd)
    meshio = pyimport("meshio")
catch
    using Conda
    Conda.add_channel("conda-forge")
    Conda.add("meshio")
    meshio = pyimport("meshio")
end
