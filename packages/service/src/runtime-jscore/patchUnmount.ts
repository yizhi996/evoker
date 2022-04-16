import {
  queuePostFlushCb,
  VNode,
  callWithAsyncErrorHandling,
  ComponentInternalInstance,
  ErrorCodes,
  EffectScope,
  Fragment,
  ComponentOptions
} from "vue"
import { invokeArrayFns } from "@nzoth/shared"

const enum ShapeFlags {
  ELEMENT = 1,
  FUNCTIONAL_COMPONENT = 1 << 1,
  STATEFUL_COMPONENT = 1 << 2,
  TEXT_CHILDREN = 1 << 3,
  ARRAY_CHILDREN = 1 << 4,
  SLOTS_CHILDREN = 1 << 5,
  TELEPORT = 1 << 6,
  SUSPENSE = 1 << 7,
  COMPONENT_SHOULD_KEEP_ALIVE = 1 << 8,
  COMPONENT_KEPT_ALIVE = 1 << 9,
  COMPONENT = ShapeFlags.STATEFUL_COMPONENT | ShapeFlags.FUNCTIONAL_COMPONENT
}

const enum PatchFlags {
  TEXT = 1,
  CLASS = 1 << 1,
  STYLE = 1 << 2,
  PROPS = 1 << 3,
  FULL_PROPS = 1 << 4,
  HYDRATE_EVENTS = 1 << 5,
  STABLE_FRAGMENT = 1 << 6,
  KEYED_FRAGMENT = 1 << 7,
  UNKEYED_FRAGMENT = 1 << 8,
  NEED_PATCH = 1 << 9,
  DYNAMIC_SLOTS = 1 << 10,
  DEV_ROOT_FRAGMENT = 1 << 11,
  HOISTED = -1,
  BAIL = -2
}

type VNodeMountHook = (vnode: VNode) => void

type VNodeHook = VNodeMountHook | VNodeMountHook[]

type LifecycleHook<Function> = Function[] | null

const isAsyncWrapper = (i: ComponentInternalInstance | VNode): boolean =>
  !!(i.type as ComponentOptions).__asyncLoader

export function unmount(
  vnode: VNode,
  parentComponent: ComponentInternalInstance | null,
  optimized: boolean = false
) {
  const { type, props, children, dynamicChildren, shapeFlag, patchFlag, dirs } =
    vnode as VNode & { dynamicChildren: VNode[] }

  const shouldInvokeDirs = shapeFlag & ShapeFlags.ELEMENT && dirs
  const shouldInvokeVnodeHook = !isAsyncWrapper(vnode)

  let vnodeHook: VNodeHook | undefined | null
  if (
    shouldInvokeVnodeHook &&
    (vnodeHook = props && props.onVnodeBeforeUnmount)
  ) {
    invokeVNodeHook(vnodeHook, parentComponent, vnode)
  }

  if (shapeFlag & ShapeFlags.COMPONENT) {
    unmountComponent(vnode.component!)
  } else {
    if (
      dynamicChildren &&
      // #1153: fast path should not be taken for non-stable (v-for) fragments
      (type !== Fragment ||
        (patchFlag > 0 && patchFlag & PatchFlags.STABLE_FRAGMENT))
    ) {
      // fast path for block nodes: only need to unmount dynamic children.
      unmountChildren(dynamicChildren, parentComponent, true)
    } else if (
      (type === Fragment &&
        patchFlag &
          (PatchFlags.KEYED_FRAGMENT | PatchFlags.UNKEYED_FRAGMENT)) ||
      (!optimized && shapeFlag & ShapeFlags.ARRAY_CHILDREN)
    ) {
      unmountChildren(children as VNode[], parentComponent)
    }
  }

  if (
    (shouldInvokeVnodeHook && (vnodeHook = props && props.onVnodeUnmounted)) ||
    shouldInvokeDirs
  ) {
    queuePostFlushCb(() => {
      vnodeHook && invokeVNodeHook(vnodeHook, parentComponent, vnode)
    })
  }
}

export function unmountChildren(
  children: VNode[],
  parentComponent: ComponentInternalInstance | null,
  optimized: boolean = false,
  start = 0
) {
  for (let i = start; i < children.length; i++) {
    unmount(children[i], parentComponent, optimized)
  }
}

export function unmountComponent(instance: ComponentInternalInstance) {
  const { bum, scope, update, subTree, um } =
    instance as ComponentInternalInstance & {
      um: LifecycleHook<Function>
      bum: LifecycleHook<Function>
      scope: EffectScope
    }

  // beforeUnmount hook
  if (bum) {
    invokeArrayFns(bum)
  }

  // stop effects in component scope
  scope.stop()

  // update may be null if a component is unmounted before its async
  // setup has resolved.
  if (update) {
    // so that scheduler will no longer invoke it
    update.active = false
    unmount(subTree, instance)
  }
  // unmounted hook
  if (um) {
    queuePostFlushCb(um)
  }

  queuePostFlushCb(() => {
    instance.isUnmounted = true
  })
}

export function invokeVNodeHook(
  hook: VNodeHook,
  instance: ComponentInternalInstance | null,
  vnode: VNode,
  prevVNode: VNode | null = null
) {
  callWithAsyncErrorHandling(hook, instance, ErrorCodes.VNODE_HOOK, [
    vnode,
    prevVNode
  ])
}
