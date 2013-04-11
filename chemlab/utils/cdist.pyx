# distutils: language = c++
'''Speedup distance computations

'''
import numpy as np
cimport numpy as np
cimport cython

from libc.math cimport sqrt
from libcpp.vector cimport vector

@cython.boundscheck(False)
def distance_array(arr_a, arr_b, double[:] period, double cutoff):
    cdef int i, j
    cdef int na = len(arr_a), nb = len(arr_b)
    cdef int size
    cdef double dist
    
    cdef double[:] distbuf
    
    cdef double[:,:] bufa = arr_a.astype(np.double)
    cdef double[:,:] bufb = arr_b.astype(np.double)
    
    cdef vector[double] distances_v
    
    for i in range(na):
        for j in range(nb):
            if i < j:
                dist = minimum_image_distance(bufa[i], bufa[j], period)
                if dist < cutoff:
                    distances_v.push_back(dist)
    
    size = distances_v.size()
    
    distances = np.empty(size)
    distbuf = distances
    
    for i in range(size):
        distbuf[i] = distances_v[i]
    
    return distances
        

@cython.cdivision(True)
@cython.boundscheck(False)
cdef inline double minimum_image_distance(double[:] a,double[:] b, double[:] periodic):
    cdef double d[3]
    
    for i in range(3):
        d[i] = b[i] - a[i]
        d[i] = d[i] - periodic[i] * rint(d[i]/periodic[i])
    
    return sqrt(d[0]*d[0] + d[1]*d[1] + d[2]*d[2])