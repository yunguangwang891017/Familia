ifdef config
include $(config)
endif

ifndef DEPS_PATH
DEPS_PATH = $(shell pwd)/third_party
endif

ifndef PYTHON_PATH
PYTHON_PATH = $(shell python -c"import sys; print sys.prefix")
endif

ifndef PROTOC
PROTOC = ${DEPS_PATH}/bin/protoc
endif

ifndef CXX
	CXX = g++
endif
CXXFLAGS=-pipe \
  		 -W \
  		 -Wall \
  		 -fPIC \
  		 -std=c++11 \
  		 -fno-omit-frame-pointer \
  		 -fpermissive \
  		 -O3 \
  		 -ffast-math

INCPATH=-I./include/ \
		-I./include/familia \
  		-I./third_party/include

LDFLAGS_SO = -L$(DEPS_PATH)/lib -L$(PYTHON_PATH)/lib -L./build/ -lfamilia -lprotobuf -lglog -lgflags -lpython2.7

.PHONY: all
all: familia python/inference_engine.so python/topical_word_embeddings.so
	@echo $(SOURCES)
	@echo $(OBJS)
	$(CXX) $(CXXFLAGS) $(INCPATH) build/demo/inference_demo.o  $(LDFLAGS_SO) -o inference_demo
	$(CXX) $(CXXFLAGS) $(INCPATH) build/demo/doc_distance_demo.o $(LDFLAGS_SO)  -o doc_distance_demo
	$(CXX) $(CXXFLAGS) $(INCPATH) build/demo/query_doc_sim_demo.o $(LDFLAGS_SO)  -o query_doc_sim_demo
	$(CXX) $(CXXFLAGS) $(INCPATH) build/demo/word_distance_demo.o $(LDFLAGS_SO) -o word_distance_demo
	$(CXX) $(CXXFLAGS) $(INCPATH) build/demo/topic_word_demo.o $(LDFLAGS_SO) -o topic_word_demo
	$(CXX) $(CXXFLAGS) $(INCPATH) build/demo/show_topic_demo.o $(LDFLAGS_SO) -o show_topic_demo

include depends.mk

.PHONY: clean
clean:
	rm -rf inference_demo
	rm -rf doc_distance_demo
	rm -rf query_doc_sim_demo
	rm -rf word_distance_demo
	rm -rf topic_word_demo
	rm -rf show_topic_demo
	rm -rf build
	rm -rf python/cpp/*.o
	rm -rf python/*.so
	rm -rf python/*.pyc
	find src -name "*.pb.[ch]*" -delete

# third party dependency
deps: ${GLOGS} ${GFLAGS} ${PROTOBUF}
	@echo "dependency installed!"

familia: build/libfamilia.a

OBJS = $(addprefix build/, vose_alias.o inference_engine.o model.o vocab.o document.o sampler.o config.o util.o semantic_matching.o tokenizer.o \
		                   demo/inference_demo.o \
						   demo/doc_distance_demo.o \
						   demo/query_doc_sim_demo.o \
						   demo/word_distance_demo.o \
						   demo/topic_word_demo.o \
						   demo/show_topic_demo.o)

build/libfamilia.a: include/config.pb.h $(OBJS)
	@echo Target $@;
	ar crv $@ $(filter %.o, $?)

build/%.o: src/%.cpp
	@mkdir -p $(@D)
	$(CXX) $(INCPATH) $(CXXFLAGS) -MM -MT build/$*.o $< >build/$*.d
	$(CXX) $(INCPATH) $(CXXFLAGS) -c $< -o $@

# build proto
include/config.pb.h src/config.cpp : proto/config.proto
	$(PROTOC) --cpp_out=./src --proto_path=./proto $<
	mv src/config.pb.h ./include/familia
	mv src/config.pb.cc ./src/config.cpp

python/inference_engine.so : python/cpp/lda_infer_wrapper.cpp familia
	$(CXX) $(INCPATH) $(CXXFLAGS) -c $< -o python/cpp/lda_infer_wrapper.o
	$(CXX) $(INCPATH) $(CXXFLAGS) -shared python/cpp/lda_infer_wrapper.o $(LDFLAGS_SO) -o $@

python/topical_word_embeddings.so : python/cpp/topical_word_embeddings_wrapper.cpp familia
	$(CXX) $(INCPATH) $(CXXFLAGS) -c $< -o python/cpp/topical_word_embeddings_wrapper.o
	$(CXX) $(INCPATH) $(CXXFLAGS) -shared python/cpp/topical_word_embeddings_wrapper.o $(LDFLAGS_SO) -o $@

-include $(wildcard */*.d *.d)
