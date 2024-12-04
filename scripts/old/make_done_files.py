#! /usr/bin/env python

import os
import sys
import argparse

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
    parser = argparse.ArgumentParser()
    parser.add_argument('output_file')
    args=parser.parse_args()
    
    return args

def main(*args, **kwargs):
    
    if isinstance(args[0], argparse.Namespace):
        args=args[0]
    elif kwargs is not None:
        for key, value in kwargs.items():
            if not key.startswith('-'):
                key='-'+key
            args += [key, str(value)]
        args=parse_input_args(args)
        
    print(args.output_file)
    done_file = args.output_file.replace('.tif', '.done')
    with open(done_file, 'w') as f: 
        f.write('Processed before parallelization\n')
    print(done_file)
    
if __name__=='__main__':
    args=sys.argv
    main(args)