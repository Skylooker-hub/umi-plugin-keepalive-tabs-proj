import {
  IRoute,
  history,
  useAppData,
  useLocation,
  useOutlet,
  useSelectedRoutes,
} from 'umi';
import { useEffect, useState } from 'react';

type CustomIRoute = IRoute & {
  name: string;
};

interface MatchRouteType {
  title: string;
  pathname: string; //  /user/1
  children: any;
  routePath: string; // /user/:id
  icon?: any;
}

export function useMatchRoute() {
  // 获取匹配到的路由
  const selectedRoutes = useSelectedRoutes();
  // 获取路由组件实例
  const children = useOutlet();
  // 获取所有路由
  const { routes } = useAppData();
  // 获取当前url
  const { pathname } = useLocation();

  const [matchRoute, setMatchRoute] = useState<MatchRouteType | undefined>();

  // 监听pathname变了，说明路由有变化，重新匹配，返回新路由信息
  useEffect(() => {
    // 获取当前匹配的路由
    const lastRoute = selectedRoutes.at(-1);

    if (!lastRoute?.route?.path) return;

    const routeDetail = routes[(lastRoute.route as any).id];

    // 如果匹配的路由需要重定向，这里直接重定向
    if (routeDetail?.redirect) {
      history.replace(routeDetail?.redirect);
      return;
    }

    // 获取菜单名称
    const title = (lastRoute.route as CustomIRoute).name;

    setMatchRoute({
      title,
      pathname,
      children,
      routePath: lastRoute.route.path,
      icon: (lastRoute.route as any).icon, // icon是拓展出来的字段
    });
  }, [pathname]);

  return matchRoute;
}
