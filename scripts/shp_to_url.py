#!/usr/bin/env python3

import sys
import argparse
import geopandas as gpd
import fiona

'''
Script to turn shp file with REMA strip indexes into list of urls

arguments:

input_file - .shp file
--output_file - output file path and name (can also use > output_file)
'''


crs_antarctica = 'EPSG:3031'

def parse_input_args(args):
    '''
    parse_input_args: transform input argument string into a dataspace

    Parameters
    ----------
    args : iterable
        Input arguments.  Keywords should have two hyphens at the start

    Returns
    -------
    dataspace
        input arguments formatted as a namespace

    '''

    parser = argparse.ArgumentParser(description='cull out spurious values from a DEM', \
        fromfile_prefix_chars='@')
    parser.add_argument('input_file')
    parser.add_argument('--output_file', '-o', type=str, default=None)
    parser.add_argument('--index_range', '-i', type=list, default=None)
    
    args=parser.parse_args()
    
    return args

def shp_to_url(*args, **kwargs):
    
    if isinstance(args[0], argparse.Namespace):
        args=args[0]
    elif kwargs is not None:
        for key, value in kwargs.items():
            if not key.startswith('-'):
                key='-'+key
            args += [key, str(value)]
        args=parse_input_args(args)
        
    gdf = gpd.GeoDataFrame.from_file(args.input_file, crs=crs_antarctica)
    print("\n".join(list(gdf.s3url)))



def main(args=None):
    if args is None:
        args=sys.argv
    shp_to_url(args)
    
if __name__=='__main__':
    main()