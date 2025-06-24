# 自动AI发布脚本（auto_post.ps1）
# 功能：
# 1. 自动抓取百度热搜、微博热搜、Google Trends 热门关键词
# 2. 基于关键词自动AI生成高质量文章
# 3. 自动为文章添加SEO优化（meta、描述、关键词、结构化数据）
# 4. 自动发布到Hexo博客并一键部署

# 依赖：需本地已安装Python 3、openai、requests、beautifulsoup4等库
# 请在首次运行前，配置好你的OpenAI API Key（如有）

$pythonScript = @'
import os
import requests
from bs4 import BeautifulSoup
import openai
import datetime
import random

# ========== 配置区 ==========
OPENAI_API_KEY = os.getenv('OPENAI_API_KEY', 'YOUR_OPENAI_API_KEY')
BLOG_AUTHOR = '你的名字'
CATEGORIES = ['AI', '科技', '趋势', '资讯']
TAGS = ['AI', '热门', '自动化', 'SEO']
# ===========================

# 获取百度热搜
baidu = requests.get('https://top.baidu.com/board?tab=realtime').text
soup = BeautifulSoup(baidu, 'html.parser')
baidu_hot = [i.get_text() for i in soup.select('.c-single-text-ellipsis')][:10]

# 获取微博热搜
weibo = requests.get('https://s.weibo.com/top/summary').text
soup = BeautifulSoup(weibo, 'html.parser')
weibo_hot = [i.get_text() for i in soup.select('td.td-02 a')][:10]

# 获取Google Trends（中国）
google = requests.get('https://trends.google.com/trends/trendingsearches/daily/rss?geo=CN').text
soup = BeautifulSoup(google, 'xml')
google_hot = [i.title.get_text() for i in soup.find_all('item')][:10]

hot_keywords = list(set(baidu_hot + weibo_hot + google_hot))
random.shuffle(hot_keywords)

# 选取一个关键词
keyword = hot_keywords[0] if hot_keywords else 'AI趋势'

# AI生成文章
openai.api_key = OPENAI_API_KEY
prompt = f"请以'{keyword}'为主题，写一篇800字左右的高质量中文博客文章，包含SEO优化建议、结构化小标题、摘要和结论。"
response = openai.ChatCompletion.create(
    model="gpt-3.5-turbo",
    messages=[{"role": "user", "content": prompt}]
)
content = response.choices[0].message.content.strip()

# 生成SEO元信息
meta = f"---\ntitle: {keyword}\ndate: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\nauthor: {BLOG_AUTHOR}\ncategories: {CATEGORIES}\ntags: {TAGS}\ndescription: {keyword}相关趋势与分析\nkeywords: {keyword},AI,自动化,SEO\n---\n"

# 写入Hexo文章
post_dir = os.path.join('source', '_posts')
os.makedirs(post_dir, exist_ok=True)
filename = os.path.join(post_dir, f"{datetime.datetime.now().strftime('%Y%m%d_%H%M%S')}_{keyword}.md")
with open(filename, 'w', encoding='utf-8') as f:
    f.write(meta + '\n' + content)
print(f"已生成AI文章：{filename}")
'@

# 写入临时python脚本
$pyfile = "./auto_post_tmp.py"
Set-Content -Path $pyfile -Value $pythonScript -Encoding UTF8

# 检查Python依赖
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "未检测到Python，请先安装Python 3！" -ForegroundColor Red
    exit 1
}
python -m pip install --upgrade pip
python -m pip install openai requests beautifulsoup4

# 执行AI自动发文
python $pyfile

# 删除临时脚本
Remove-Item $pyfile

# 自动发布
powershell -ExecutionPolicy Bypass -File ./publish.ps1
