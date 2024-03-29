import { history } from 'umi';
import { useCallback, useEffect, useRef, useState } from 'react';
import { useMatchRoute } from './useMatchRoute';

export interface KeepAliveTab {
  title: string;
  routePath: string;
  key: string; // 这个key，后面刷新有用到它
  pathname: string;
  icon?: any;
  search?: string;
  children: any;
}

function getKey() {
  return new Date().getTime().toString();
}

export function useKeepAliveTabs() {
  const [keepAliveTabs, setKeepAliveTabs] = useState<KeepAliveTab[]>([]);
  const [activeTabRoutePath, setActiveTabRoutePath] = useState<string>('');

  const keepAliveShowEvents = useRef<Record<string, Array<() => void>>>({});
  const keepAliveHiddenEvents = useRef<Record<string, Array<() => void>>>({});

  const matchRoute = useMatchRoute();

  const onShow = useCallback(
    (cb: () => void) => {
      if (!keepAliveShowEvents.current[activeTabRoutePath]) {
        keepAliveShowEvents.current[activeTabRoutePath] = [];
      }
      keepAliveShowEvents.current[activeTabRoutePath].push(cb);
    },
    [activeTabRoutePath],
  );

  const onHidden = useCallback(
    (cb: () => void) => {
      if (!keepAliveHiddenEvents.current[activeTabRoutePath]) {
        keepAliveHiddenEvents.current[activeTabRoutePath] = [];
      }
      keepAliveHiddenEvents.current[activeTabRoutePath].push(cb);
    },
    [activeTabRoutePath],
  );

  // 关闭tab
  const closeTab = useCallback(
    (routePath: string = activeTabRoutePath) => {
      const index = keepAliveTabs.findIndex((o) => o.routePath === routePath);
      if (keepAliveTabs[index].routePath === activeTabRoutePath) {
        if (index > 0) {
          history.push({
            pathname: keepAliveTabs[index - 1].pathname,
            search: keepAliveTabs[index - 1].search,
          });
        } else {
          history.push({
            pathname: keepAliveTabs[index + 1].pathname,
            search: keepAliveTabs[index + 1].search,
          });
        }
      }
      keepAliveTabs.splice(index, 1);

      delete keepAliveHiddenEvents.current[routePath];
      delete keepAliveShowEvents.current[routePath];

      setKeepAliveTabs([...keepAliveTabs]);
    },
    [keepAliveTabs, activeTabRoutePath],
  );

  // 关闭其他
  const closeOtherTab = useCallback(
    (routePath: string = activeTabRoutePath) => {
      const toCloseTabs = keepAliveTabs.filter(
        (o) => o.routePath !== routePath,
      );
      // 清除被关闭的tab注册的onShow事件和onHidden事件
      toCloseTabs.forEach((tab) => {
        delete keepAliveHiddenEvents.current[tab.routePath];
        delete keepAliveShowEvents.current[tab.routePath];
      });

      setKeepAliveTabs((prev) => prev.filter((o) => o.routePath === routePath));

      const tab = keepAliveTabs.find((o) => o.routePath === routePath);
      history.push({pathname: tab.pathname, search: tab.search});
    },
    [keepAliveTabs, activeTabRoutePath],
  );

  // 刷新tab
  const refreshTab = useCallback(
    (routePath: string = activeTabRoutePath) => {
      setKeepAliveTabs((prev) => {
        const index = prev.findIndex((tab) => tab.routePath === routePath);

        if (index >= 0) {
          // 这个react的特性，key变了，组件会卸载重新渲染
          prev[index].key = getKey();
        }

        delete keepAliveHiddenEvents.current[prev[index].routePath];
        delete keepAliveShowEvents.current[prev[index].routePath];

        return [...prev];
      });
    },
    [activeTabRoutePath],
  );

  useEffect(() => {
    if (!matchRoute) return;

    const existKeepAliveTab = keepAliveTabs.find(
      (o) => o.routePath === matchRoute?.routePath,
    );

    setActiveTabRoutePath(matchRoute.routePath);

    // 如果不存在则需要插入
    if (!existKeepAliveTab) {
      setKeepAliveTabs((prev) => [
        ...prev,
        {
          title: matchRoute.title,
          key: getKey(),
          routePath: matchRoute.routePath,
          pathname: matchRoute.pathname,
          children: matchRoute.children,
          icon: matchRoute.icon,
          search: matchRoute.search,
        },
      ]);
    } else if (existKeepAliveTab.pathname !== matchRoute.pathname) {
      // 如果是同一个路由，但是参数不同，我们只需要刷新当前页签并且把pathname设置为新的pathname， children设置为新的children
      setKeepAliveTabs((prev) => {
        const index = prev.findIndex(
          (tab) => tab.routePath === matchRoute.routePath,
        );

        if (index >= 0) {
          prev[index].key = getKey();
          prev[index].pathname = matchRoute.pathname;
          prev[index].children = matchRoute.children;
          prev[index].search = matchRoute.search;
        }

        delete keepAliveHiddenEvents.current[prev[index].routePath];
        delete keepAliveShowEvents.current[prev[index].routePath];

        return [...prev];
      });
    } else if (existKeepAliveTab.search !== matchRoute.search) {
      // search不同
      setKeepAliveTabs((prev) => {
        const index = prev.findIndex(
          (tab) => tab.routePath === matchRoute.routePath,
        );

        if (index >= 0) {
          prev[index].key = getKey();
          prev[index].children = matchRoute.children;
          prev[index].search = matchRoute.search;
        }

        delete keepAliveHiddenEvents.current[prev[index].routePath];
        delete keepAliveShowEvents.current[prev[index].routePath];

        return [...prev];
      });
    } else {
      // 如果存在，触发组件的onShow的回调
      (keepAliveShowEvents.current[existKeepAliveTab.routePath] || []).forEach(
        (cb) => {
          cb();
        },
      );
    }

    // 路由改变，执行上一个tab的onHidden事件
    (keepAliveHiddenEvents.current[activeTabRoutePath] || []).forEach((cb) => {
      cb();
    });
  }, [matchRoute]);

  return {
    keepAliveTabs,
    setKeepAliveTabs,
    activeTabRoutePath,
    closeTab,
    refreshTab,
    closeOtherTab,
    onShow,
    onHidden,
  };
}
