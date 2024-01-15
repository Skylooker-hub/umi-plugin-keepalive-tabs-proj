# umi-plugin-keepalive-tabs

A umi plugin

学习自前端小付的文章[手把手带你实现一个多页签umi插件](https://juejin.cn/post/7228749296320725050)

 1. 可拖拽tabs
 2. 选择”关闭其他“时，自动跳转，避免空白页
 3. 不使用国际化插件

## Install

```bash
pnpm i @huang1997/umi-plugin-keepalive-tabs

## 需要安装的依赖
pnpm add @dnd-kit/core @dnd-kit/modifiers @dnd-kit/sortable @dnd-kit/utilities

```

## Usage

Configure in `.umirc.ts`,

```js
export default {
  plugins: [
    ['@huang1997/umi-plugin-keepalive-tabs'],
  ],
}
```

## Options

TODO

## LICENSE

MIT
