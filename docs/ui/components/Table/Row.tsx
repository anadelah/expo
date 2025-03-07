import { css } from '@emotion/react';
import { theme } from '@expo/styleguide';
import React, { PropsWithChildren } from 'react';

type RowProps = PropsWithChildren<{
  subtle?: boolean;
}>;

export const Row = ({ children, subtle }: RowProps) => (
  <tr css={[tableRowStyle, subtle && subtleStyle]}>{children}</tr>
);

const tableRowStyle = css({
  '&:nth-of-type(2n)': {
    backgroundColor: theme.background.secondary,

    summary: {
      backgroundColor: theme.background.tertiary,
    },
  },
});

const subtleStyle = css({
  opacity: '0.5',
});
