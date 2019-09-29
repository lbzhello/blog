#### 创建一个名为 my-app 的目录（应用）

    yarn create react-app my-app

其目录结构如下：

my-app
├── README.md
├── node_modules
├── package.json
├── .gitignore
├── public
│   ├── favicon.ico
│   ├── index.html
│   └── manifest.json
└── src
    ├── App.css
    ├── App.js
    ├── App.test.js
    ├── index.css
    ├── index.js
    ├── logo.svg
    └── serviceWorker.js

#### 启动应用

    yarn start

浏览器打开 http://localhost:3000 查看显示效果

#### 测试应用

    yarn test

#### 构建应用

    yarn build

在 build 目录下生成面向生产的静态文件