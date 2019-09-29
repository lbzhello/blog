## 元素渲染

html 中声明一个容器

```html
<div id="app"></div>
```
将元素渲染到 html

```jsx
const element = <h1>Hello, world!</h1>;
ReactDOM.render(
    element,
    document.getElementById('app')
);
```

## 创建组件

```jsx
// hello world
class HelloWorld extends React.Component {
    render() {
        return (
            <div>
                <h1>Hello, world!</h1>
                <h2>现在是 {this.props.date.toLocaleTimeString()}.</h2>
            </div>
        );
    }
}

// hello world 函数组件
function helloWorld(props) {
    return (
        <div>
            <h1>Hello, world!</h1>
            <h2>现在是 {props.date.toLocaleTimeString()}.</h2>
        </div>
    );
}
 
ReactDOM.render(
    <HelloWorld date={new Date()} />,
    document.getElementById('example')
);
```