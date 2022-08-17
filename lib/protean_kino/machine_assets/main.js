import smcat from 'https://esm.sh/v90/state-machine-cat@10.0.1/es2022/state-machine-cat.bundle.js'

const commonOverrides = [
  // { name: 'fontname', value: '"Iosevka Web"' },
  { name: 'fontsize', value: '8' },
]

const statechartToSVG = (ast) => {
  return smcat.render(ast, {
    inputType: 'json',
    outputType: 'svg',
    dotGraphAttrs: [
      { name: 'width', value: '0.1' },
      { name: 'height', value: '0.1' },
      ...commonOverrides
    ],
    dotNodeAttrs: [
      { name: 'penwidth', value: '1' },
      { name: 'width', value: '0.1' },
      { name: 'height', value: '0.1' },
      ...commonOverrides
    ],
    dotEdgeAttrs: [
      ...commonOverrides
    ]
  })
}

const renderSVG = (ast, target) => {
  const svg = statechartToSVG(ast)
  const parser = new DOMParser()
  const svgNode = parser.parseFromString(svg, "image/svg+xml").documentElement
  svgNode.setAttribute('width', '100%')
  target.replaceChildren(svgNode)
}

export function init(ctx, ast) {
  ctx.importCSS('https://pvinis.github.io/iosevka-webfont/3.4.1/iosevka.css')

  renderSVG(ast, ctx.root)

  ctx.handleEvent("replace", ast => {
    renderSVG(ast, ctx.root)
  })
}
