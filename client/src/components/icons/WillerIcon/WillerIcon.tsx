import { Icon, IconProps, useColorModeValue } from '@chakra-ui/react'
import { ReactJSXElement } from '@emotion/react/types/jsx-namespace'

const WillerIcon = ({
  isInverted = false,
  fill,
  ...rest
}: {
  fill?: string
  isInverted?: boolean
} & IconProps): ReactJSXElement => {
  const lightMode = isInverted ? 'white' : 'gray.800'
  const darkMode = isInverted ? 'gray.800' : 'white'

  const iconFill = fill || useColorModeValue(lightMode, darkMode)

  return (
    <Icon viewBox="0 0 32 11.5" {...rest} width={["20mm", "31.863mm"]} height="10.979mm">
      <path
        xmlns="http://www.w3.org/2000/svg"
        d="M 10.205,5.2804 Q 10.205,9.2738 7.1147,11.348 L 5.4637,9.556 3.9115,11.32 Q 3.3894,11.221 2.7262,10.826 1.2163,9.9229 0.70835,8.8364 0.2568,7.905 0.2568,6.0283 V 0.42627 H 2.5992 V 5.9154 Q 2.5992,6.9173 2.8109,7.4676 3.0931,8.2296 3.8692,8.6106 V 0.42627 H 6.3104 V 5.5062 Q 6.3104,6.7197 6.4656,7.2559 6.6773,8.0038 7.3969,8.7235 7.7074,7.905 7.8061,7.4253 7.919,6.875 7.919,6.0283 7.919,3.8976 6.6773,2.1055 L 9.0197,0.62382 Q 10.205,2.5711 10.205,5.2804 Z" 
        fill={iconFill}
      />
      <path
        xmlns="http://www.w3.org/2000/svg"
        d="M 13.987,1.8374 12.59,3.2343 11.193,1.8374 12.59,0.44038 Z M 13.634,11.263 H 11.348 V 3.7423 H 13.634 Z"
        fill={iconFill}
      />
      <path
        xmlns="http://www.w3.org/2000/svg"
        d="M 17.514,11.235 H 15.2 V 0.42627 H 17.514 Z"
        fill={iconFill}
      />
      <path
        xmlns="http://www.w3.org/2000/svg"
        d="M 21.268,11.235 H 18.954 V 0.42627 H 21.268 Z"
        fill={iconFill}
      />
      <path
        xmlns="http://www.w3.org/2000/svg"
        d="M 27.773,5.6614 24.965,8.6953 Q 25.558,9.2738 26.531,9.6125 L 24.852,11.405 Q 23.596,10.911 23.032,10.219 22.397,9.4431 22.397,8.1732 V 5.224 L 25.247,3.3755 Z M 25.515,6.5504 24.556,5.478 V 7.5099 Z"
        fill={iconFill}
      />
      <path
        xmlns="http://www.w3.org/2000/svg"
        d="M 32.119,3.319 31.837,6.2964 Q 31.131,5.3933 30.496,5.3933 V 11.235 H 28.182 V 3.7141 H 30.412 V 4.2927 Q 31.329,3.4883 32.119,3.319 Z"
        fill={iconFill}
      />      
    </Icon>
  )
}

export default WillerIcon