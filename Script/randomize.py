#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
简化版JSON随机化脚本 - 专门用于finoBoxer_mapper.JSON
"""

import re
import json
import random
import os

# 词库配置文件路径
WORD_CONFIG_PATH = 'word_config.json'
# JSON文件路径
JSON_FILE_PATH = 'selector_mapper.JSON'
# 输出文件路径
OUTPUT_FILE_PATH = 'selector_mapper_randomized.JSON'
# 特殊字符列表，用于清理词汇
TRIM_CHARS = [':', ' ', '-', '_', '(', ')', '[', ']', '{', '}', '"', "'", '\\', '/', ';', ',', '.']
# 是否使用驼峰命名法
CAMEL_CASE = False
# 一个单词对应生成的最大单词数量
RANDOM_NUMBER_MAX = 3

class Randomize:
    """随机化类"""

    def __init__(self, word_config_path, json_file_path, output_file_path):
        self.word_config_path = word_config_path
        self.json_file_path = json_file_path
        self.output_file_path = output_file_path
        self.keywords = []
        self.random_words = []
        self.load_word_config()
    
    def load_word_config(self):
        """加载词库配置文件"""
        config_file = self.word_config_path

        if not os.path.exists(config_file):
            print(f"❌ 错误：词库配置文件 '{config_file}' 不存在")
            return None
        
        def clean_word(word):
            """清理词汇，去除特殊字符"""
            return ''.join(c for c in word if c not in TRIM_CHARS)  
        
        try:
            with open(config_file, 'r', encoding='utf-8') as f:
                config = json.load(f)
                self.keywords = set(config.get('keywords', []))
                self.random_words = [clean_word(word) for word in config.get('random_words', []) if word not in self.keywords]
                print(f"📚 已加载词库：关键词({len(self.keywords)})，随机词汇({len(self.random_words)})")
        except Exception as e:
            print(f"❌ 加载词库配置失败：{e}")
            return None

    def get_random_value(self, original_value):
        """根据原值特征生成随机值"""
        if original_value == "":
            return ""
        
        random_values = []
        random_number = random.randint(1, RANDOM_NUMBER_MAX)
        while len(random_values) < random_number:
            # 如果原值是保护的关键词，随机选择一个随机词汇
            random_value = random.choice(self.random_words)
            if not random_value in random_values:
                random_values.append(random_value)
                
        return random_values
    
    def split_camel_case(self, text):
        """将驼峰命名法的字符串分割成单词列表"""
        # 使用正则表达式分割驼峰命名
        # (?<=[a-z])(?=[A-Z]) 匹配小写字母后跟大写字母的位置
        # (?<=[A-Z])(?=[A-Z][a-z]) 匹配大写字母后跟大写字母+小写字母的位置（处理连续大写字母）
        words = re.sub(r'(?<=[a-z])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])', ' ', text).split()
        return [word for word in words if word]
    
    def join_words(self, words):
        """将单词列表拼接成字符串"""
        if not words:
            return ""
        if CAMEL_CASE:
            # 驼峰命名法：第一个字母小写，后续字母大写
            return words[0].lower() + ''.join(word.capitalize() for word in words[1:])
        else:
            # 下划线连接
            return '_'.join([word.lower() for word in words])
    
    def get_random_string(self, original_value):
        """生成一个随机字符串，长度与原值相同"""
        if original_value == "":
            return ""
        # 以:分隔字符串，并且用驼峰或者_识别单词
        # 驼峰拼接成一个字符串，第一个字母小写
        common_words = [word for word in re.split(r'[:]', original_value)]

        result_string = []
        for word in common_words:
            # 对每个单词进行处理
            words = [w for w in re.split(r'[_]', word) if w]
            
            # 进一步处理驼峰命名法分割
            all_words = []
            for w in words:
                camel_words = self.split_camel_case(w)
                all_words.extend(camel_words)
            
            if len(all_words) == 0:
                continue    
            # 获取每个单词的随机值
            random_list = []
            for random_word in all_words:
                random_list.extend([item.capitalize() for item in self.get_random_value(random_word)])
                if len(random_list) > 0:
                    random_list[0] = random_list[0].lower()

            result_string.append(self.join_words(random_list))
            
        return ':'.join(result_string) + ':'

    # 递归替换所有字符串值
    def randomize_recursive(self, obj):
        if isinstance(obj, dict):
            return {key: self.randomize_recursive(value) for key, value in obj.items()}
        elif isinstance(obj, str):
            return self.get_random_string(obj)
        else:
            return obj

    def randomize(self):
        """主函数：随机化JSON文件"""
        # 读取原文件
        with open(self.json_file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)

        # 随机化数据
        randomized_data = self.randomize_recursive(data)

        # 保存到新文件
        with open(OUTPUT_FILE_PATH, 'w', encoding='utf-8') as f:
            json.dump(randomized_data, f, indent=2, ensure_ascii=False)
    
        print("✅ 随机化完成！")
        print(f"📁 原文件：{JSON_FILE_PATH}")
        print(f"📁 新文件：{OUTPUT_FILE_PATH}")
    
if __name__ == "__main__":
    # 测试驼峰分割功能
    randomizer = Randomize(WORD_CONFIG_PATH, JSON_FILE_PATH, OUTPUT_FILE_PATH)
    randomizer.randomize()
    # 测试驼峰字符串随机化
    # camel_result = randomizer.get_random_string("provider:Zenith:")
    # print(f"驼峰字符串随机化：providerZenith: -> {camel_result}")
