FLAGS= -DDEBUG
LIBS= -lm
ALWAYS_REBUILD=makefile

nbody: nbody.o compute.o
	gcc $(FLAGS) $^ -o $@ $(LIBS)
nbody.o: nbody.c planets.h config.h vector.h $(ALWAYS_REBUILD)
	gcc $(FLAGS) -c $< 
compute.o: compute.c config.h vector.h $(ALWAYS_REBUILD)
	gcc $(FLAGS) -c $< 
parallel: nbody.cu compute_parallel.cuh config.h vector.h planets.h
	nvcc $(FLAGS) nbody.cu -o parallel $(LIBS)
clean:
	rm -f *.o nbody 
