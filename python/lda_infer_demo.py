#coding=utf8

# Copyright (c) 2017, Baidu.com, Inc. All Rights Reserved
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
#
# Author: lianrongzhong@baidu.com

import sys
from inference_engine_wrapper import InferenceEngineWrapper

if __name__ == '__main__':
    if len(sys.argv) < 3:
        sys.stderr.write("python {} {} {}\n".format(
            sys.argv[1], "model_dir", "conf_file"))
        exit(-1)
    # 获取参数
    model_dir = sys.argv[1]
    conf_file = sys.argv[2]
    # 创建InferenceEngineWrapper对象
    inference_engine_wrapper = InferenceEngineWrapper(model_dir, conf_file)
    while True:
        input_text = raw_input("Enter Document: ")
        # 分词
        seg_list = inference_engine_wrapper.tokenize(input_text)
        # 进行推断
        topic_dist = inference_engine_wrapper.lda_infer(seg_list)
        # 打印结果
        print "Document Topic Distribution:"
        print topic_dist
