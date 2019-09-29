#### 获取表单数据
```jsx
<input
    type="text"
    value={this.state.value}
    onChange={(e) => {
        this.setState({
            value: e.target.value.toUpperCase(),
        });
    }}
/>
```