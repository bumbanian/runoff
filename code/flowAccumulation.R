library(terra)

# Load mean annual P-E layer
pme = rast("bigdata/qs_ann.tif")

# Load DEM, downloaded from EarthExplorer 11-1-2024
dem = rast("bigdata/na_dem.bil")

## Set nodata values correctly
demv = values(dem, mat = FALSE)
demv = replace(demv, demv == 55537, NA)
demv = replace(demv, demv > 10000, -1)
values(dem) = demv

## crop
dem = crop(dem, pme)

writeRaster(dem, "bigdata/dem.tif", overwrite = TRUE, NAflag = -9999)

# Fill pits
system("mpiexec -n 8 pitremove -z bigdata/dem.tif -fel bigdata/dem_fill.tif")

# Flow direction
system("mpiexec -n 8 D8Flowdir -fel bigdata/dem_fill.tif -p bigdata/fd.tif")

# Flow accumulation -> streamflow
system("mpiexec -n 8 AreaD8 -p bigdata/fd.tif -wg bigdata/qs_ann.tif -ad8 bigdata/sf.tif")

sf = rast("bigdata/sf.tif")
plot(sf, mar = c(2, 2, 2, 6))
