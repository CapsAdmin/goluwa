function diff(
	parentDom,
	newVNode,
	oldVNode,
	globalContext,
	isSvg,
	excessDomChildren,
	commitQueue,
	oldDom,
	isHydrating
) end

function commitRoot(commitQueue, root) end

function diffElementNodes(
	dom,
	newVNode,
	oldVNode,
	globalContext,
	isSvg,
	excessDomChildren,
	commitQueue,
	isHydrating
) end

function applyRef(ref, value, vnode) end

function unmount(vnode, parentVNode, skipRemove) end

function doRender(props, state, context) end