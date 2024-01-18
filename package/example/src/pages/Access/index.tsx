import { PageContainer } from '@ant-design/pro-components';
import { Access, Link, useAccess } from '@umijs/max';
import { Button } from 'antd';

const AccessPage: React.FC = () => {
  const access = useAccess();
  return (
    <PageContainer
      ghost
      header={{
        title: '权限示例',
      }}
    >
      <Access accessible={access.canSeeAdmin}>
        <Button>只有 Admin 可以看到这个按钮</Button>
      </Access>
      <Link
        to={{
          pathname: '/table',
          search: '?id=1',
        }}
      >
        table page with search
      </Link>
    </PageContainer>
  );
};

export default AccessPage;
